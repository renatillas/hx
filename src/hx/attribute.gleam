import hx/queue
import hx/timing

/// Synchronization options for coordinating AJAX requests
pub type Sync {
  Default(css_selector: String)
  Drop(css_selector: String)
  Abort(css_selector: String)
  Replace(css_selector: String)
  SyncQueue(css_selector: String, queue: queue.Queue)
}

/// Different ways content can be swapped in the DOM
pub type Swap {
  InnerHTML
  OuterHTML
  After
  Afterbegin
  Beforebegin
  Beforeend
  Afterend
  Delete
  SwapNone
}

/// Scroll position specification
pub type Scroll {
  Top
  Bottom
}

/// Options for modifying swap behavior
pub type SwapConfig {
  Transition(Bool)
  SwapTiming(timing.Timing)
  Settle(timing.Timing)
  IgnoreTitle(Bool)
  ScrollTo(Scroll)
  Show(Scroll)
  FocusScroll(Bool)
}

pub fn swap_option_to_string(swap_option: SwapConfig) {
  case swap_option {
    Transition(True) -> "transition:true"
    Transition(False) -> "transition:false"
    SwapTiming(timing_declaration) ->
      "swap:" <> timing.to_string(timing_declaration)
    Settle(timing_declaration) ->
      "settle:" <> timing.to_string(timing_declaration)
    IgnoreTitle(True) -> "ignoreTitle:true"
    IgnoreTitle(False) -> "ignoreTitle:false"
    ScrollTo(Top) -> "scroll:top"
    ScrollTo(Bottom) -> "scroll:bottom"
    Show(Top) -> "show:top"
    Show(Bottom) -> "show:bottom"
    FocusScroll(True) -> "focus-scroll:true"
    FocusScroll(False) -> "focus-scroll:false"
  }
}

pub fn swap_to_string(swap: Swap) {
  case swap {
    InnerHTML -> "innerHTML"
    OuterHTML -> "outerHTML"
    After -> "after"
    Afterbegin -> "afterBegin"
    Beforebegin -> "beforeBegin"
    Beforeend -> "beforeEnd"
    Afterend -> "afterEnd"
    Delete -> "delete"
    SwapNone -> "none"
  }
}

pub fn sync_option_to_string(sync_option: Sync) -> String {
  case sync_option {
    Default(css_selector) -> "default:" <> css_selector
    Drop(css_selector) -> "drop:" <> css_selector
    Abort(css_selector) -> "abort:" <> css_selector
    Replace(css_selector) -> "replace:" <> css_selector
    SyncQueue(css_selector, queue) ->
      "queue:" <> css_selector <> " " <> queue.to_string(queue)
  }
}
