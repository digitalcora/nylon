import nylon/posix

/// Error type returned by most `socket` operations that accept a timeout.
pub type Error {
  /// See `nylon/socket/error`.
  Closed

  /// See `nylon/posix`.
  Posix(posix.Error)

  /// The specified timeout was exceeded.
  Timeout
}
