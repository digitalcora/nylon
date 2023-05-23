import nylon/socket/async

pub type Disposition {
  Normal(flags: List(Flag))
  Continue(async.SelectInfo)
}

pub type Flag {
  Eor
  More
}
