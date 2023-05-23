/// Error type returned by `socket.transfer`.
pub type Error {
  /// See `nylon/socket/error`.
  Closed

  /// This process is not the current owner of the socket.
  NotOwner
}
