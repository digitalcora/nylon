//// Functions for performing low-level socket operations.
////
//// > #### ⚠ Warning!
//// >
//// > This module is an intentionally thin layer over Erlang's
//// > [`socket`](https://www.erlang.org/doc/man/socket.html) module, which is
//// > itself a thin layer over the POSIX socket functions provided by operating
//// > systems. It is primarily useful as a foundation for building higher-level
//// > Gleam libraries that specialize in a specific protocol like TCP or UDP.
//// > It is **probably not what you want** if you just want to _use_ one of
//// > those protocols in a Gleam application.

import gleam/dynamic.{Dynamic}
import gleam/erlang/atom
import gleam/erlang/process
import gleam/option.{Option}
import nylon/posix
import nylon/socket/address.{Address}
import nylon/socket/async
import nylon/socket/cancel
import nylon/socket/connect
import nylon/socket/connect_until
import nylon/socket/error
import nylon/socket/listen
import nylon/socket/open
import nylon/socket/recv
import nylon/socket/send
import nylon/socket/shutdown
import nylon/socket/timeout
import nylon/socket/transfer

/// A socket is an interface for sending and receiving data using networking
/// protocols. New sockets are created using [`open`](#open). When the program
/// is done using a socket, it should be closed using [`close`](#close).
///
/// Note that sockets are **mutable** objects managed by the operating system,
/// and can be in a variety of states. Most functions that accept a `Socket`
/// have some restrictions on what state the socket can be in, and will return
/// an error otherwise. The specifics are noted in each function's docs.
///
/// Like Erlang processes, it is possible to "leak" a socket by never closing
/// it, allowing it to consume system resources forever. To guard against this,
/// sockets are always attached to a process (initially the process that
/// created them) called the **owner**. When the owner dies, the socket is
/// automatically closed. The [`transfer`](#transfer) function allows changing
/// the socket owner.
pub external type Socket

pub type AcceptResult =
  Result(Socket, error.Error)

pub type ConnectResult =
  Result(Nil, connect.Error)

pub type RecvResult =
  Result(BitString, #(error.Error, Option(BitString)))

pub type SendResult =
  Result(Option(BitString), #(error.Error, Option(BitString)))

pub type Message {
  Select(Socket, async.SelectHandle)
  Abort(Socket, async.SelectHandle, async.AbortReason)
  Completion(Socket, async.CompletionHandle, Dynamic)
}

pub external fn accept(Socket) -> AcceptResult =
  "socket_ffi" "accept_forever"

pub external fn accept_async(Socket) -> async.Result(Socket, Nil, error.Error) =
  "socket_ffi" "accept_nowait"

pub external fn accept_result(
  Dynamic,
) -> Result(AcceptResult, List(dynamic.DecodeError)) =
  "socket_ffi" "decode_accept_result"

pub external fn accept_until(
  Socket,
  timeout: Int,
) -> Result(Socket, timeout.Error) =
  "socket_ffi" "accept"

/// Return the address the socket is bound to (see `bind`).
///
/// **Windows:** Returns `Error(Posix(Einval))` if the socket is unbound.
pub external fn address(Socket) -> Result(Address, error.Error) =
  "socket_ffi" "address"

/// Bind a socket to an address. This determines the address to `connect` from
/// or `listen` on. `address` retrieves the currently bound address.
///
/// On Unix, unbound sockets behave as though they are bound to some default
/// address, usually an "any" IP address. On Windows, `address`, `connect`, and
/// `listen` return an error when used with an unbound socket.
///
/// Note that binding to a local path creates the specified file (or "socket
/// object"), but does _not_ automatically delete it when the socket is closed.
/// Use [`file.delete`][delete] to remove it.
///
/// [delete]: https://hexdocs.pm/gleam_erlang/gleam/erlang/file.html#delete
///
/// Common POSIX errors:
///
/// * `Einval`: The socket is already bound. Binding is "permanent"; to free up
///   the bound address or use a different one, the socket must be closed and a
///   new one opened.
///
/// * `Eaddrinuse`: For IP sockets, another program is already bound to the
///   given address, or `address.assign_port` was used and there are no free
///   ports in the ephemeral range. For local sockets, the path already exists.
///
/// * `Eaddrnotavail`: The address cannot be bound. For IP sockets, indicates
///   the address does not match any of the machine's network interfaces.
///
/// * `Eacces`: The current user does not have permission to bind the address.
///   For IP sockets, this may occur when using a port number less than 1024,
///   which is often not allowed unless running as `root`. For local sockets,
///   the user may not have search permission on one of the directories in the
///   path.
///
/// * `Enoent`/`Enotdir`: For local sockets, one of the directories in the path
///   does not exist or is not a directory, respectively.
///
/// * `Enotsup`: For local sockets, the path is not an absolute path.
pub external fn bind(Socket, Address) -> Result(Nil, error.Error) =
  "socket_ffi" "bind"

pub external fn cancel_completion(
  Socket,
  async.CompletionInfo,
) -> Result(Nil, cancel.Error) =
  "socket_ffi" "cancel"

pub external fn cancel_select(
  Socket,
  async.SelectInfo,
) -> Result(Nil, cancel.Error) =
  "socket_ffi" "cancel"

pub external fn connect(Socket, Address) -> ConnectResult =
  "socket_ffi" "connect_forever"

pub external fn connect_async(
  Socket,
  Address,
) -> async.Result(Socket, Nil, connect.Error) =
  "socket_ffi" "connect_nowait"

pub external fn connect_finish(Socket) -> Result(Nil, error.Error) =
  "socket_ffi" "connect_finish"

pub external fn connect_result(
  Dynamic,
) -> Result(ConnectResult, List(dynamic.DecodeError)) =
  "socket_ffi" "decode_connect_result"

pub external fn connect_until(
  Socket,
  Address,
  Int,
) -> Result(Nil, connect_until.Error) =
  "socket_ffi" "connect"

/// Close a socket, freeing up the underlying system resources.
///
/// Operations waiting on the socket will immediately return `Error(Closed)`,
/// and passing the socket to any `socket` functions from this point on will
/// return the same error.
///
/// It is not expected that this function will ever return a POSIX error. The
/// best option if it does is probably to `panic`.
///
// TODO: note about streams
// TODO: `Timeout` = linger timeout expired without all buffered data being sent
pub external fn close(Socket) -> Result(Nil, timeout.Error) =
  "socket_ffi" "close"

pub external fn listen(Socket) -> Result(Nil, listen.Error) =
  "socket_ffi" "listen"

pub external fn listen_with(Socket, backlog: Int) -> Result(Nil, listen.Error) =
  "socket_ffi" "listen"

/// Create a new socket. The domain, type, and protocol determine what kind of
/// socket is created; see the `socket/open` module for the types and meanings
/// of these arguments.
///
/// Generally the next step is to [`bind`](#bind) the socket to an address.
///
/// Common POSIX errors:
///
/// * `Eafnosupport`: The specified domain is not supported.
///
/// * `Eprotonosupport`: The specified type or protocol is not supported with
///   the specified domain.
///
/// * `Eacces`: The system denied permission to create a socket of this type.
///   Typically only occurs when opening a `Raw` socket, which are restricted
///   to privileged users.
pub external fn open(
  open.Domain,
  open.Type,
  open.Protocol,
  List(open.Option),
) -> Result(Socket, posix.Error) =
  "socket_ffi" "open"

pub external fn recv(Socket, length: Int, flags: List(recv.Flag)) -> RecvResult =
  "socket_ffi" "recv_forever"

pub external fn recv_async(
  Socket,
  length: Int,
  flags: List(recv.Flag),
) -> async.Result(
  BitString,
  Option(BitString),
  #(error.Error, Option(BitString)),
) =
  "socket_ffi" "recv_nowait"

pub external fn recv_result(
  Dynamic,
) -> Result(RecvResult, List(dynamic.DecodeError)) =
  "socket_ffi" "decode_recv_result"

pub external fn recv_until(
  Socket,
  length: Int,
  flags: List(recv.Flag),
  timeout: Int,
) -> Result(BitString, #(timeout.Error, Option(BitString))) =
  "socket_ffi" "recv"

pub fn selecting_async(
  selector: process.Selector(a),
  mapping transform: fn(Message) -> a,
) -> process.Selector(a) {
  let assert Ok(atom_socket) = atom.from_string("$socket")

  process.selecting_record4(
    selector,
    atom_socket,
    fn(elem2, elem3, elem4) {
      translate_async_message(elem2, elem3, elem4)
      |> transform()
    },
  )
}

pub external fn send(Socket, BitString, send.Disposition) -> SendResult =
  "socket_ffi" "send_forever"

pub external fn send_async(
  Socket,
  BitString,
  send.Disposition,
) -> async.Result(Option(BitString), Option(BitString), error.Error) =
  "socket_ffi" "send_nowait"

pub external fn send_result(
  Dynamic,
) -> Result(SendResult, List(dynamic.DecodeError)) =
  "socket_ffi" "decode_send_result"

pub external fn send_until(
  Socket,
  BitString,
  send.Disposition,
  timeout: Int,
) -> Result(Option(BitString), #(timeout.Error, Option(BitString))) =
  "socket_ffi" "send"

pub external fn shutdown(Socket, shutdown.Which) -> Result(Nil, error.Error) =
  "socket_ffi" "shutdown"

/// Transfer ownership of a socket to the specified process.
///
/// When the owner of a socket dies, or is already dead when ownership is
/// transferred to it, the socket is automatically closed. The initial owner of
/// a socket is the process that created it.
///
/// Only the existing owner can transfer a socket.
pub external fn transfer(Socket, process.Pid) -> Result(Nil, transfer.Error) =
  "socket_ffi" "transfer"

external fn translate_async_message(Dynamic, Dynamic, Dynamic) -> Message =
  "socket_ffi" "translate_async_message"
