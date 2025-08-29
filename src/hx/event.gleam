import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import hx/css_selector
import hx/queue
import hx/timing

/// Event triggers with optional modifiers
pub opaque type Event {
  Event(event: String, modifiers: List(EventModifier))
}

/// Modifiers that change event behavior
pub opaque type EventModifier {
  Once
  Changed
  Delay(timing.Timing)
  Throttle(timing.Timing)
  From(extended_css_selector: css_selector.Selector)
  Target(css_selector: String)
  Consume
  QueueEvent(Option(queue.Queue))
}

// ==== COMMON DOM EVENTS ====

/// Creates a load event that fires when the element loads
pub fn load() -> Event {
  Event(event: "load", modifiers: [])
}

/// Creates a DOMContentLoaded event 
pub fn dom_content_loaded() -> Event {
  Event(event: "DOMContentLoaded", modifiers: [])
}

/// Creates a click event
pub fn click() -> Event {
  Event(event: "click", modifiers: [])
}

/// Creates a change event (useful for form inputs)
pub fn change() -> Event {
  Event(event: "change", modifiers: [])
}

/// Creates a submit event (useful for forms)
pub fn submit() -> Event {
  Event(event: "submit", modifiers: [])
}

/// Creates a keyup event
pub fn keyup() -> Event {
  Event(event: "keyup", modifiers: [])
}

/// Creates a keydown event  
pub fn keydown() -> Event {
  Event(event: "keydown", modifiers: [])
}

/// Creates a focus event
pub fn focus() -> Event {
  Event(event: "focus", modifiers: [])
}

/// Creates a blur event
pub fn blur() -> Event {
  Event(event: "blur", modifiers: [])
}

/// Creates a mouseover event
pub fn mouseover() -> Event {
  Event(event: "mouseover", modifiers: [])
}

/// Creates a mouseout event
pub fn mouseout() -> Event {
  Event(event: "mouseout", modifiers: [])
}

/// Creates an input event (fires on every character input)
pub fn input() -> Event {
  Event(event: "input", modifiers: [])
}

/// Creates a scroll event
pub fn scroll() -> Event {
  Event(event: "scroll", modifiers: [])
}

/// Creates a resize event
pub fn resize() -> Event {
  Event(event: "resize", modifiers: [])
}

// ==== HTMX-SPECIFIC EVENTS ====

/// Creates an htmx:beforeRequest event
pub fn htmx_before_request() -> Event {
  Event(event: "htmx:beforeRequest", modifiers: [])
}

/// Creates an htmx:afterRequest event  
pub fn htmx_after_request() -> Event {
  Event(event: "htmx:afterRequest", modifiers: [])
}

/// Creates an htmx:beforeSwap event
pub fn htmx_before_swap() -> Event {
  Event(event: "htmx:beforeSwap", modifiers: [])
}

/// Creates an htmx:afterSwap event
pub fn htmx_after_swap() -> Event {
  Event(event: "htmx:afterSwap", modifiers: [])
}

/// Creates an htmx:beforeSettle event
pub fn htmx_before_settle() -> Event {
  Event(event: "htmx:beforeSettle", modifiers: [])
}

/// Creates an htmx:afterSettle event
pub fn htmx_after_settle() -> Event {
  Event(event: "htmx:afterSettle", modifiers: [])
}

/// Creates an htmx:load event
pub fn htmx_load() -> Event {
  Event(event: "htmx:load", modifiers: [])
}

/// Creates an htmx:configRequest event
pub fn htmx_config_request() -> Event {
  Event(event: "htmx:configRequest", modifiers: [])
}

/// Creates an htmx:responseError event
pub fn htmx_response_error() -> Event {
  Event(event: "htmx:responseError", modifiers: [])
}

/// Creates an htmx:sendError event
pub fn htmx_send_error() -> Event {
  Event(event: "htmx:sendError", modifiers: [])
}

/// Creates an htmx:timeout event
pub fn htmx_timeout() -> Event {
  Event(event: "htmx:timeout", modifiers: [])
}

/// Creates an htmx:validation:validate event
pub fn htmx_validation_validate() -> Event {
  Event(event: "htmx:validation:validate", modifiers: [])
}

/// Creates an htmx:validation:failed event
pub fn htmx_validation_failed() -> Event {
  Event(event: "htmx:validation:failed", modifiers: [])
}

/// Creates an htmx:validation:halted event
pub fn htmx_validation_halted() -> Event {
  Event(event: "htmx:validation:halted", modifiers: [])
}

/// Creates an htmx:xhr:abort event
pub fn htmx_xhr_abort() -> Event {
  Event(event: "htmx:xhr:abort", modifiers: [])
}

/// Creates an htmx:xhr:loadend event
pub fn htmx_xhr_loadend() -> Event {
  Event(event: "htmx:xhr:loadend", modifiers: [])
}

/// Creates an htmx:xhr:loadstart event
pub fn htmx_xhr_loadstart() -> Event {
  Event(event: "htmx:xhr:loadstart", modifiers: [])
}

/// Creates an htmx:xhr:progress event  
pub fn htmx_xhr_progress() -> Event {
  Event(event: "htmx:xhr:progress", modifiers: [])
}

// ==== INTERSECT EVENTS ====

/// Creates an intersect event with options
pub fn intersect(options: Option(String)) -> Event {
  case options {
    Some(opts) ->
      Event(event: "intersect", modifiers: [
        From(css_selector.CssSelector(opts)),
      ])
    None -> Event(event: "intersect", modifiers: [])
  }
}

/// Creates an intersect event that fires only once
pub fn intersect_once(options: Option(String)) -> Event {
  case options {
    Some(opts) ->
      Event(event: "intersect", modifiers: [
        From(css_selector.CssSelector(opts)),
        Once,
      ])
    None -> Event(event: "intersect", modifiers: [Once])
  }
}

// ==== EVENT HELPER FUNCTIONS ====

/// Creates a custom event with the given name
pub fn custom(event_name: String) -> Event {
  Event(event: event_name, modifiers: [])
}

/// Adds a delay modifier to an existing event
pub fn with_delay(event: Event, timing: timing.Timing) -> Event {
  Event(event: event.event, modifiers: [Delay(timing), ..event.modifiers])
}

/// Adds a throttle modifier to an existing event  
pub fn with_throttle(event: Event, timing: timing.Timing) -> Event {
  Event(event: event.event, modifiers: [Throttle(timing), ..event.modifiers])
}

/// Adds a once modifier to an existing event
pub fn with_once(event: Event) -> Event {
  Event(event: event.event, modifiers: [Once, ..event.modifiers])
}

/// Adds a changed modifier to an existing event
pub fn with_changed(event: Event) -> Event {
  Event(event: event.event, modifiers: [Changed, ..event.modifiers])
}

/// Adds a from modifier to an existing event
pub fn with_from(
  event: Event,
  extended_css_selector: css_selector.Selector,
) -> Event {
  Event(event: event.event, modifiers: [
    From(extended_css_selector),
    ..event.modifiers
  ])
}

/// Adds a target modifier to an existing event
pub fn with_target(event: Event, css_selector: String) -> Event {
  Event(event: event.event, modifiers: [Target(css_selector), ..event.modifiers])
}

/// Adds a consume modifier to an existing event
pub fn with_consume(event: Event) -> Event {
  Event(event: event.event, modifiers: [Consume, ..event.modifiers])
}

/// Adds a queue modifier to an existing event
pub fn with_queue(event: Event, queue: Option(queue.Queue)) -> Event {
  Event(event: event.event, modifiers: [QueueEvent(queue), ..event.modifiers])
}

fn modifier_to_string(event_modifier event_modifier: EventModifier) {
  case event_modifier {
    Once -> "once"
    Changed -> "changed"
    Delay(t) -> "delay:" <> timing.to_string(t)
    Throttle(t) -> "throttle:" <> timing.to_string(t)
    From(extended_css_selector) ->
      "from:" <> css_selector.to_string(extended_css_selector)
    Target(css_selector) -> "target:" <> css_selector
    Consume -> "consume"
    QueueEvent(Some(queue)) -> "queue:" <> queue.to_string(queue)
    QueueEvent(None) -> "queue: none"
  }
}

pub fn to_string(event: Event) {
  event.event
  <> list.map(event.modifiers, fn(e) { " " <> modifier_to_string(e) })
  |> string.join("")
}
