import gleam/dynamic.{Dynamic}

pub external type SelectTag

pub external type SelectHandle

pub external type CompletionTag

pub external type CompletionHandle

pub type SelectInfo {
  SelectInfo(SelectTag, SelectHandle)
}

pub type CompletionInfo {
  CompletionInfo(CompletionTag, CompletionHandle)
}

pub type Result(a, b, c) {
  Ok(a)
  Select(SelectInfo, b)
  Completion(CompletionInfo)
  Error(c)
}

pub type AbortReason {
  Closed
  Unknown(Dynamic)
}
