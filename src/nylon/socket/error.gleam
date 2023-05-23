import nylon/posix

/// Error type returned by most `socket` operations with no timeout.
pub type Error {
  /// The socket is closed or (for stream sockets) the required direction has
  /// been shut down. As an example of the latter, `recv` on a stream socket
  /// will return `Error(Closed)` if the read side is closed, though the write
  /// side and/or the socket itself may still be open.
  Closed

  /// See `nylon/posix`.
  Posix(posix.Error)
}
