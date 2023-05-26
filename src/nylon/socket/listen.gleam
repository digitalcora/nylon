import nylon/posix

/// Error type returned by `socket.listen`.
pub type Error {
  /// See `nylon/socket/error`.
  Closed

  /// **Windows:** The socket is not bound to an address (see `socket.bind`).
  NotBound

  /// See `nylon/posix`.
  Posix(posix.Error)
}
