/// Error type returned by `socket.cancel_*`.
pub type Error {
  /// See `nylon/socket/error`.
  Closed

  /// The async operation has already been completed or canceled, or does not
  /// belong to this process.
  Invalid
}
