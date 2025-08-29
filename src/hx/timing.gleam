import gleam/int

/// Timing specification for HTMX operations
pub type Timing {
  Seconds(Int)
  Milliseconds(Int)
}

pub fn to_string(timing: Timing) {
  case timing {
    Seconds(n) -> int.to_string(n) <> "s"
    Milliseconds(n) -> int.to_string(n) <> "ms"
  }
}
