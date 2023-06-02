//// Functions for working with Internet Protocol addresses.

/// An IP address. Wraps an Erlang [`inet:ip_address`][erl-ip].
///
/// [erl-ip]: https://www.erlang.org/doc/man/inet.html#type-ip_address
pub opaque type Address {
  Inet(#(Int, Int, Int, Int))
  Inet6(#(Int, Int, Int, Int, Int, Int, Int, Int))
}

/// An IP address family.
pub type Family {
  V4
  V6
}

/// The IPv4 "any" address (`0.0.0.0`). Used to request that a socket be bound
/// to any/all available interfaces. Using this as a "destination" address will
/// always return an error.
pub const any_v4 = Inet(#(0, 0, 0, 0))

/// The IPv6 "any" address (`::`).
pub const any_v6 = Inet6(#(0, 0, 0, 0, 0, 0, 0, 0))

/// The IPv4 loopback address (`127.0.0.1`).
pub const loopback_v4 = Inet(#(127, 0, 0, 1))

/// The IPv6 loopback address (`::1`).
pub const loopback_v6 = Inet6(#(0, 0, 0, 0, 0, 0, 0, 1))

/// Return the family of an address.
pub fn family(address: Address) -> Family {
  case address {
    Inet(..) -> V4
    Inet6(..) -> V6
  }
}

/// Construct an address from a string representation.
///
/// Accepts standard IPv4 and IPv6 notations. Hex digits in IPv6 addresses are
/// case-insensitive.
pub external fn parse(String) -> Result(Address, Nil) =
  "ip_ffi" "address_parse"

/// Return a string representation of an address in canonical format.
pub external fn to_string(Address) -> String =
  "ip_ffi" "address_to_string"
