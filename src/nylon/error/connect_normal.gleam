import nylon/posix

pub type Error {
  Already
  Closed
  NotBound
  Posix(posix.Error)
}
