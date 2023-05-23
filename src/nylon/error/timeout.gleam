import nylon/posix

pub type Error {
  Closed
  Posix(posix.Error)
  Timeout
}
