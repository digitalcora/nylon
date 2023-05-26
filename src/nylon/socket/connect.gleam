import nylon/posix

/// Error type returned by `socket.connect`.
pub type Error {
  /// Another process is already in a `connect` call on this socket.
  ///
  /// Note if the socket _is_ already connected, the error returned is
  /// `Posix(Eisconn)`.
  Already

  /// See `nylon/socket/error`.
  Closed

  /// **Windows:** The socket is not bound to an address (see `socket.bind`).
  NotBound

  /// See `nylon/posix`.
  Posix(posix.Error)
}
