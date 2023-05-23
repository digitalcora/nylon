import nylon/posix

/// Error type returned by `socket.connect_until`.
pub type Error {
  /// See `nylon/socket/connect/error`.
  Already

  /// See `nylon/socket/error`.
  Closed

  /// See `nylon/socket/connect/error`.
  NotBound

  /// See `nylon/posix`.
  Posix(posix.Error)

  /// The specified timeout was exceeded.
  ///
  /// ⚠ See the documentation for `socket.connect_until`.
  Timeout
}
