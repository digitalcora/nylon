//// Functions for working with socket addresses.
////
//// A "socket address" contains the information needed to send or receive data
//// on a socket. For example, an IP socket address contains both the IP address
//// itself and a port number.

import gleam/bit_string
import nylon/ip

/// A socket address. Specifically, an Erlang [`socket:sockaddr`][erl-addr].
///
/// [erl-addr]: https://www.erlang.org/doc/man/socket.html#type-sockaddr
pub external type Address

/// An IP port number.
pub opaque type Port {
  Port(Int)
}

/// Special value used to request that an IP socket be bound to any available
/// port in the ephemeral range. Using this as a "destination" port (e.g. with
/// `connect`) will always return an error.
///
/// After binding with this value, the address of the socket (`socket.address`)
/// will include the actual port number that was assigned.
pub const assign_port = Port(0)

/// The maximum length of a local socket path in bytes.
pub const path_max_bytes = 108

/// Construct a socket address from an IP address and port.
pub external fn ip(ip.Address, Port) -> Address =
  "socket_ffi" "sockaddr_in"

/// Construct a "local" socket address, also known as a "Unix domain socket".
///
/// The path should be an absolute path to a filename, where all directories in
/// the path exist but the file does not (it is created by `socket.bind`). This
/// function cannot validate the path, as the file system may change before it
/// is used. See `socket.bind` for errors that may result from an invalid path.
///
/// There is a limit on the length of a socket path (see `path_max_bytes`). If
/// the given path is longer than this, `Error(Nil)` is returned.
pub fn local(path: String) -> Result(Address, Nil) {
  case
    path
    |> bit_string.from_string()
    |> bit_string.byte_size()
  {
    size if size <= path_max_bytes -> Ok(do_local(path))
    _size -> Error(Nil)
  }
}

/// Construct a validated `Port`. If the given number is out of bounds for an
/// IP port number, returns `Error(Nil)`.
///
/// See `assign_port` for a more convenient constant version of "port 0".
pub fn port(num: Int) -> Result(Port, Nil) {
  case num {
    num if num >= 0 && num <= 65_535 -> Ok(Port(num))
    _num -> Error(Nil)
  }
}

external fn do_local(String) -> Address =
  "socket_ffi" "sockaddr_un"
