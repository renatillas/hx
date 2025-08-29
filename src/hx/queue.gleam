/// Queue behavior for synchronized requests
pub type Queue {
  First
  Last
  All
}

pub fn to_string(queue: Queue) -> String {
  case queue {
    First -> "first"
    Last -> "last"
    All -> "all"
  }
}
