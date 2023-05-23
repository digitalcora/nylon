import gleam/bit_string
import gleam/dynamic.{Dynamic}
import gleam/int
import gleam/list
import gleam/map
import gleam/result
import gleam/string
import nylon/erl

/// `socket:sockaddr`
pub type Address {
  /// `socket:sockaddr_in`
  IPv4(addr: IPv4, port: Port)

  /// `socket:sockaddr_in6`
  IPv6(addr: IPv6, port: Port)

  /// `socket:sockaddr_un`
  Unix(path: Path)
}

/// `socket:in_addr`
pub opaque type IPv4 {
  V4(#(Int, Int, Int, Int))
}

/// `socket:in6_addr`
pub opaque type IPv6 {
  V6(#(Int, Int, Int, Int, Int, Int, Int, Int), Int)
}

pub opaque type Path {
  Path(String)
}

/// `socket:port_number`
pub opaque type Port {
  Port(Int)
}

pub const any_v4 = V4(#(0, 0, 0, 0))

pub const any_v6 = V6(#(0, 0, 0, 0, 0, 0, 0, 0), 0)

pub const broadcast_v4 = V4(#(255, 255, 255, 255))

pub const loopback_v4 = V4(#(127, 0, 0, 1))

pub const loopback_v6 = V6(#(0, 0, 0, 0, 0, 0, 0, 1), 0)

const u8_max = 255

const u16_max = 65_535

const u32_max = 4_294_967_295

const unix_socket_path_max_bytes = 104

pub fn parse_v4(addr: String) -> Result(IPv4, Nil) {
  case
    addr
    |> string.split(".")
    |> list.map(int.parse)
    |> list.map(validate_int(_, u8_max))
    |> result.all()
  {
    Ok([o1, o2, o3, o4]) -> Ok(V4(#(o1, o2, o3, o4)))
    _other -> Error(Nil)
  }
}

pub fn port(num: Int) -> Result(Port, Nil) {
  case num {
    num if num >= 0 && num <= u16_max -> Ok(Port(num))
    _num -> Error(Nil)
  }
}

/// Convert an `Address` to an Erlang `socket:sockaddr`.
pub fn to_sockaddr(addr: Address) -> Dynamic {
  case addr {
    IPv4(V4(parts), Port(port)) ->
      map.from_list([
        erl.kv("family", erl.atom("inet")),
        erl.kv("port", port),
        erl.kv("addr", parts),
      ])

    IPv6(V6(parts, scope_id), Port(port)) ->
      map.from_list([
        erl.kv("family", erl.atom("inet6")),
        erl.kv("port", port),
        erl.kv("addr", parts),
        erl.kv("scope_id", scope_id),
      ])

    Unix(Path(path)) ->
      map.from_list([erl.kv("family", erl.atom("local")), erl.kv("path", path)])
  }
  |> dynamic.from()
}

pub fn unix_path(path: String) -> Result(Path, Nil) {
  case
    path
    |> bit_string.from_string()
    |> bit_string.byte_size()
  {
    size if size <= unix_socket_path_max_bytes -> Ok(Path(path))
    _size -> Error(Nil)
  }
}

fn validate_int(parse_result: Result(Int, Nil), max: Int) -> Result(Int, Nil) {
  case parse_result {
    Ok(num) ->
      case num {
        num if num >= 0 && num <= max -> Ok(num)
        _num -> Error(Nil)
      }

    Error(Nil) -> Error(Nil)
  }
}
