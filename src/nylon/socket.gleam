import gleam/dynamic.{Dynamic}
import gleam/erlang/process.{Pid}
import gleam/option.{Option}
import nylon/address.{Address}
import nylon/error/connect_normal
import nylon/error/connect_timeout
import nylon/error/normal
import nylon/error/timeout
import nylon/posix
import nylon/socket/async
import nylon/socket/cancel
import nylon/socket/open
import nylon/socket/recv
import nylon/socket/send
import nylon/socket/shutdown
import nylon/socket/transfer

pub external type Socket

pub type AcceptResult =
  Result(Socket, normal.Error)

pub type ConnectResult =
  Result(Nil, connect_normal.Error)

pub type RecvResult =
  Result(BitString, #(normal.Error, Option(BitString)))

pub type SendResult =
  Result(Option(BitString), #(normal.Error, Option(BitString)))

pub type Message {
  Select(Socket, async.SelectHandle)
  Completion(Socket, async.CompletionHandle, CompletionStatus)
  Abort(Socket, async.SelectHandle, normal.Error)
}

pub type CompletionStatus {
  AcceptStatus(AcceptResult)
  ConnectStatus(ConnectResult)
  RecvStatus(RecvResult)
  SendStatus(SendResult)
}

pub external fn accept(Socket) -> AcceptResult =
  "nylon_ffi" "accept_forever"

pub external fn accept_async(Socket) -> async.Result(Socket, Nil, normal.Error) =
  "nylon_ffi" "accept_nowait"

pub external fn accept_until(
  Socket,
  timeout: Int,
) -> Result(Socket, timeout.Error) =
  "nylon_ffi" "accept"

pub fn bind(socket: Socket, address: Address) -> Result(Nil, normal.Error) {
  do_bind(socket, address.to_sockaddr(address))
}

pub external fn cancel_completion(
  Socket,
  async.CompletionInfo,
) -> Result(Nil, cancel.Error) =
  "nylon_ffi" "cancel"

pub external fn cancel_select(
  Socket,
  async.SelectInfo,
) -> Result(Nil, cancel.Error) =
  "nylon_ffi" "cancel"

pub fn connect(socket: Socket, addr: Address) -> ConnectResult {
  do_connect(socket, address.to_sockaddr(addr))
}

pub fn connect_async(
  socket: Socket,
  addr: Address,
) -> async.Result(Socket, Nil, connect_normal.Error) {
  do_connect_async(socket, address.to_sockaddr(addr))
}

pub fn connect_until(
  socket: Socket,
  addr: Address,
  timeout timeout: Int,
) -> Result(Nil, connect_timeout.Error) {
  do_connect_until(socket, address.to_sockaddr(addr), timeout)
}

// `Timeout` = linger timeout expired without all buffered data being sent
pub external fn close(Socket) -> Result(Nil, timeout.Error) =
  "nylon_ffi" "close"

pub external fn listen(Socket) -> Result(Nil, normal.Error) =
  "nylon_ffi" "listen"

pub external fn listen_with(Socket, backlog: Int) -> Result(Nil, normal.Error) =
  "nylon_ffi" "listen"

pub external fn open(
  open.Domain,
  open.Type,
  open.Protocol,
  List(open.Option),
) -> Result(Socket, posix.Error) =
  "nylon_ffi" "open"

pub external fn recv(Socket, length: Int, flags: List(recv.Flag)) -> RecvResult =
  "nylon_ffi" "recv_forever"

pub external fn recv_async(
  Socket,
  length: Int,
  flags: List(recv.Flag),
) -> async.Result(
  BitString,
  Option(BitString),
  #(normal.Error, Option(BitString)),
) =
  "nylon_ffi" "recv_nowait"

pub external fn recv_until(
  Socket,
  length: Int,
  flags: List(recv.Flag),
  timeout: Int,
) -> Result(BitString, #(timeout.Error, Option(BitString))) =
  "nylon_ffi" "recv"

pub external fn send(Socket, BitString, send.Disposition) -> SendResult =
  "nylon_ffi" "send_forever"

pub external fn send_async(
  Socket,
  BitString,
  send.Disposition,
) -> async.Result(Option(BitString), Option(BitString), normal.Error) =
  "nylon_ffi" "send_nowait"

pub external fn send_until(
  Socket,
  BitString,
  send.Disposition,
  timeout: Int,
) -> Result(Option(BitString), #(timeout.Error, Option(BitString))) =
  "nylon_ffi" "send"

pub external fn shutdown(Socket, shutdown.Which) -> Result(Nil, normal.Error) =
  "nylon_ffi" "shutdown"

/// Transfer ownership of a socket to the specified process.
///
/// When the owner of a socket dies, or is already dead when ownership is
/// transferred to it, the socket is automatically closed. The initial owner of
/// a socket is the process that created it.
///
/// Only the existing owner can transfer a socket.
pub external fn transfer(Socket, Pid) -> Result(Nil, transfer.Error) =
  "nylon_ffi" "transfer"

external fn do_bind(Socket, Dynamic) -> Result(Nil, normal.Error) =
  "nylon_ffi" "bind"

external fn do_connect(Socket, Dynamic) -> ConnectResult =
  "nylon_ffi" "connect_forever"

external fn do_connect_async(
  Socket,
  Dynamic,
) -> async.Result(Socket, Nil, connect_normal.Error) =
  "nylon_ffi" "connect_nowait"

external fn do_connect_until(
  Socket,
  Dynamic,
  Int,
) -> Result(Nil, connect_timeout.Error) =
  "nylon_ffi" "connect"
