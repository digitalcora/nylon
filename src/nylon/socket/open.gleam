pub type Domain {
  Inet
  Inet6
  Local
  Unspec
}

pub type Option {
  Netns(String)
  Debug(Bool)
  UseRegistry(Bool)
}

pub type Protocol {
  Default
  Ip
  Ipv6
  Sctp
  Tcp
  Udp
}

pub type Type {
  Dgram
  Raw
  // Rdm
  Seqpacket
  Stream
}
