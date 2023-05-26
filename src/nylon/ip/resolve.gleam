//// Enables resolving names to IP addresses or vice-versa.

import nylon/posix
import nylon/ip.{Address}

pub type Error {
  /// No results were found.
  NotFound

  /// An error occurred; see `nylon/posix`.
  Posix(posix.Error)
}

/// The result of resolving a host name.
pub type Host {
  Host(
    /// The canonical name of the host, and any aliases.
    ///
    /// Normally aliases are only returned if the name was resolved using a
    /// local "hosts file" that maps multiple names to the same address. Hosts
    /// resolved using DNS will not have any aliases, unless the name used was
    /// a `CNAME`, in which case that name (only) will appear as an alias.
    names: #(String, List(String)),
    /// The IP addresses of the host. Provided as a tuple because at least one
    /// address is always present; if no addresses were found, `Error(NotFound)`
    /// would have been returned instead.
    addresses: #(Address, List(Address)),
  )
}

/// Look up the canonical name for a given address.
pub external fn address(Address) -> Result(String, Error) =
  "ip_ffi" "resolve_address"

/// Look up addresses for a given name.
///
/// The name can be a bare name (`localhost`), a domain name (`gleam.run`), or
/// an IP address (`127.0.0.1`). Note in the latter case this simply "echoes"
/// back the address (if valid) in the form of a `Host`, and does not look up a
/// canonical name; for that, see `address`.
///
/// If the string is not a valid host name, returns `Error(Posix(Einval))`.
pub external fn name(String, ip.Family) -> Result(Host, Error) =
  "ip_ffi" "resolve_name"
