//// Types used by `socket.open`.

/// Determines what kind of address is used with a socket.
///
/// This documentation uses "IP socket" as shorthand for a socket with either
/// `Inet` or `Inet6` domain.
pub type Domain {
  /// IPv4 addressing (see `address.ip`).
  Inet

  /// IPv6 addressing (see `address.ip`).
  ///
  /// > ⚠ IPv6 support in the underlying `socket` module is called out as "not
  /// > fully tested". Use with caution.
  Inet6

  /// Local addressing, also known as "Unix domain" (see `address.local`).
  Local
}

/// Determines how data is sent and received on a socket.
pub type Type {
  /// Data is sent and received in small fixed-size chunks ("datagrams"). The
  /// protocol does not guarantee datagrams will be received in the order they
  /// are sent, or that they will be received exactly once (or at all).
  ///
  /// The default protocol for IP sockets with this type is UDP.
  Dgram

  /// Data is sent and received as a continuous stream of bytes, via a
  /// "connection" established with a remote address. The protocol guarantees
  /// bytes are received exactly once, in the order they were sent. If data is
  /// lost and cannot be recovered, the connection is terminated.
  ///
  /// The default protocol for IP sockets with this type is TCP.
  Stream

  /// Similar to `Stream` but allows a data sender to add out-of-band "record
  /// boundaries" to the data stream (see `send.Eor` and `recv.Eor`).
  ///
  /// The default protocol for IP sockets with this type is SCTP.
  Seqpacket

  /// Data is sent and received as raw IP datagrams (this type can only be used
  /// with IP sockets). This allows implementing custom protocols on top of IP,
  /// or performing low-level operations such as sending ICMP messages.
  ///
  /// Because this mode is easily used for nefarious purposes, it requires that
  /// the Erlang VM is running as:
  ///
  /// * **Unix:** `root` or a user with the `CAP_NET_RAW` capability
  /// * **Windows:** a user in the local Administrators group
  ///
  /// If this is not the case, `socket.open` will return an `Eacces` error.
  Raw
}

/// Determines the specific network protocol used for a socket.
pub type Protocol {
  /// Indicates the system should choose a default protocol based on the domain
  /// and type. `Local` sockets _must_ use this value.
  Default

  /// UDP. Only valid with IP domains and `Dgram` type.
  Udp

  /// TCP. Only valid with IP domains and `Stream` type.
  Tcp

  /// SCTP. Only valid with IP domains and `Stream` or `Seqpacket` types.
  ///
  /// > ⚠ SCTP support in the underlying `socket` module is marked as "partly
  /// > implemented and not tested". Use with caution.
  Sctp

  /// Raw IPv4. Only valid with `Raw` type.
  Ip

  /// Raw IPv6. Only valid with `Raw` type.
  Ipv6
}

/// Options for `socket.open`.
pub type Option {
  /// When `True`, enables debug output during the `open` call. To enable debug
  /// output for further socket operations, ...TODO...
  ///
  /// Default: `False`
  Debug(Bool)

  /// **Unix:** Set the network namespace for the socket. Ignored on Windows.
  Netns(String)

  /// When `True`, the socket is added to a global registry that can be queried
  /// by the Erlang function [`socket:which_sockets`][ws]. This library
  /// currently does not provide a Gleam wrapper for this function.
  ///
  /// Default: `True`
  ///
  /// The default can be changed globally by [`socket:use_registry/1`][ur].
  ///
  /// [ws]: https://www.erlang.org/doc/man/socket.html#which_sockets-0
  /// [ur]: https://www.erlang.org/doc/man/socket.html#use_registry-1
  UseRegistry(Bool)
}
