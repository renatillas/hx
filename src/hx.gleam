//// # hx - Gleam HTMX Bindings
////
//// Type-safe Gleam bindings for HTMX attributes and events.
////
//// ## Links
//// - [HTMX Documentation](https://htmx.org/)
//// - [HTMX Attributes Reference](https://htmx.org/reference/#attributes)
//// - [HTMX Events Reference](https://htmx.org/reference/#events)
////
//// ## Basic Usage
////
//// ```gleam
//// import hx
//// import lustre/element/html
////
//// html.button([
////   hx.get("/api/users"),
////   hx.target(hx.CssSelector("#results")),
////   hx.swap(hx.InnerHTML),
//// ], [html.text("Load Users")])
//// ```

import gleam/float
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/time/duration
import lustre/attribute.{attribute}

/// Specifies which events will cause an HTMX request.
///
/// [Official Documentation](https://htmx.org/attributes/hx-trigger/)
///
/// ## Examples
/// ```gleam
/// // Single event
/// hx.trigger([hx.click()])
///
/// // Multiple events
/// hx.trigger([hx.click(), hx.keyup()])
///
/// // Event with modifiers
/// hx.trigger([hx.with_delay(hx.click(), duration.seconds(2))])
/// ```
pub fn trigger(events: List(Event)) {
  let events =
    events
    |> list.map(event_to_string)
    |> string.join(", ")
  attribute("hx-trigger", events)
}

/// Creates a polling trigger that fires at regular intervals.
///
/// [Official Documentation](https://htmx.org/attributes/hx-trigger/)
///
/// ## Examples
/// ```gleam
/// // Poll every 5 seconds
/// hx.trigger_polling(timing: duration.seconds(5), filters: None, on_load: False)
///
/// // Poll with filters
/// hx.trigger_polling(timing: duration.seconds(10), filters: Some("visible"), on_load: False)
///
/// // Start polling immediately and on load
/// hx.trigger_polling(timing: duration.seconds(2), filters: None, on_load: True)
/// ```
pub fn trigger_polling(
  timing timing: duration.Duration,
  filters filters: Option(String),
  on_load on_load: Bool,
) {
  case filters, on_load {
    Some(filters), False ->
      attribute(
        "hx-trigger",
        "every " <> duration_to_string(timing) <> " [" <> filters <> "]",
      )
    None, False ->
      attribute("hx-trigger", "every " <> duration_to_string(timing))
    None, True ->
      attribute("hx-trigger", "load every " <> duration_to_string(timing))
    Some(filters), True ->
      attribute(
        "hx-trigger",
        "load every " <> duration_to_string(timing) <> " [" <> filters <> "]",
      )
  }
}

/// Issues a GET request to the given URL when the element is triggered.
///
/// [Official Documentation](https://htmx.org/attributes/hx-get/)
pub fn get(url url: String) {
  attribute("hx-get", url)
}

/// Issues a POST request to the given URL when the element is triggered.
///
/// [Official Documentation](https://htmx.org/attributes/hx-post/)
pub fn post(url url: String) {
  attribute("hx-post", url)
}

/// Issues a PUT request to the given URL when the element is triggered.
///
/// [Official Documentation](https://htmx.org/attributes/hx-put/)
pub fn put(url url: String) {
  attribute("hx-put", url)
}

/// Issues a PATCH request to the given URL when the element is triggered.
///
/// [Official Documentation](https://htmx.org/attributes/hx-patch/)
pub fn patch(url url: String) {
  attribute("hx-patch", url)
}

/// Issues a DELETE request to the given URL when the element is triggered.
///
/// [Official Documentation](https://htmx.org/attributes/hx-delete/)
pub fn delete(url url: String) {
  attribute("hx-delete", url)
}

/// Shows loading indicators during AJAX requests.
///
/// Supports extended CSS selectors including `closest`, `this`, etc.
///
/// [Official Documentation](https://htmx.org/attributes/hx-indicator/)
pub fn indicator(selector: Selector) {
  attribute("hx-indicator", selector_to_string(selector))
}

/// Specifies the target element to swap content into.
///
/// [Official Documentation](https://htmx.org/attributes/hx-target/)
///
/// ## Examples
/// ```gleam
/// // Target specific element
/// hx.target(hx.Selector("#results"))
///
/// // Target parent element
/// hx.target(hx.Closest(".card"))
///
/// // Target the element itself
/// hx.target(hx.This)
/// ```
pub fn target(extended_css_selector extended_css_selector: Selector) {
  attribute("hx-target", selector_to_string(extended_css_selector))
}

/// Controls how content is swapped into the DOM.
///
/// [Official Documentation](https://htmx.org/attributes/hx-swap/)
///
/// ## Examples
/// ```gleam
/// // Basic swap strategies
/// hx.swap(hx.InnerHTML)
/// hx.swap(hx.OuterHTML)
/// hx.swap(hx.Afterend)
/// ```
pub fn swap(swap swap: Swap) {
  swap
  |> swap_to_string
  |> attribute("hx-swap", _)
}

/// Controls how content is swapped into the DOM with additional configuration options.
///
/// [Official Documentation](https://htmx.org/attributes/hx-swap/)
///
/// ## Examples
/// ```gleam
/// // Swap with transition
/// hx.swap_with(hx.InnerHTML, hx.Transition(True))
///
/// // Swap with timing
/// hx.swap_with(hx.OuterHTML, hx.SwapTiming(duration.milliseconds(500)))
/// ```
pub fn swap_with(swap swap: Swap, config config: SwapConfig) {
  swap
  |> swap_to_string
  |> string.append(" " <> swap_option_to_string(config))
  |> attribute("hx-swap", _)
}

/// Allows you to swap content "out of band" - updating other elements in the response.
///
/// [Official Documentation](https://htmx.org/attributes/hx-swap-oob/)
pub fn swap_oob(swap swap: Swap, css_selector css_selector: Option(String)) {
  case css_selector {
    Some(css_selector) ->
      swap
      |> swap_to_string
      |> string.append(":" <> css_selector)
      |> attribute("hx-swap-oob", _)
    None ->
      swap
      |> swap_to_string
      |> attribute("hx-swap-oob", _)
  }
}

/// Allows you to swap content "out of band" with configuration options.
///
/// [Official Documentation](https://htmx.org/attributes/hx-swap-oob/)
pub fn swap_oob_with(
  swap swap: Swap,
  css_selector css_selector: Option(String),
  config modifier: SwapConfig,
) {
  case css_selector {
    Some(css_selector) -> {
      swap
      |> swap_to_string
      |> string.append(":" <> css_selector)
      |> string.append(" " <> swap_option_to_string(modifier))
      |> attribute("hx-swap-oob", _)
    }
    None -> {
      swap
      |> swap_to_string
      |> string.append(" " <> swap_option_to_string(modifier))
      |> attribute("hx-swap-oob", _)
    }
  }
}

/// Synchronizes AJAX requests between elements.
///
/// [Official Documentation](https://htmx.org/attributes/hx-sync/)
///
/// ## Examples
/// ```gleam
/// // Use default drop behavior (strategy is optional)
/// hx.sync(hx.Default(hx.Closest("form")))
///
/// // Explicitly drop conflicting requests
/// hx.sync(hx.Drop(hx.Closest("form")))
///
/// // Abort current request if new one comes in
/// hx.sync(hx.Abort(hx.This))
///
/// // Queue requests, keeping only the last
/// hx.sync(hx.Queue(hx.Selector("#form"), hx.Last))
/// ```
pub fn sync(strategy: Sync) {
  attribute("hx-sync", sync_option_to_string(strategy))
}

/// Selects a subset of the server response to process.
///
/// [Official Documentation](https://htmx.org/attributes/hx-select/)
pub fn select(css_selector: String) {
  attribute("hx-select", css_selector)
}

/// Selects content from a response to be swapped in out-of-band.
///
/// Accepts a comma-separated list of CSS selectors for elements to swap out-of-band.
///
/// [Official Documentation](https://htmx.org/attributes/hx-select-oob/)
pub fn select_oob(css_selectors: List(String)) {
  let selectors = css_selectors |> string.join(",")
  attribute("hx-select-oob", selectors)
}

/// Pushes a URL into the browser's location bar and history.
///
/// [Official Documentation](https://htmx.org/attributes/hx-push-url/)
pub fn push_url(bool: Bool) {
  case bool {
    True -> attribute("hx-push-url", "true")
    False -> attribute("hx-push-url", "false")
  }
}

/// Shows a confirmation dialog before making a request.
///
/// [Official Documentation](https://htmx.org/attributes/hx-confirm/)
pub fn confirm(confirm_text: String) {
  attribute("hx-confirm", confirm_text)
}

/// Progressive enhancement for links and forms using AJAX.
///
/// [Official Documentation](https://htmx.org/attributes/hx-boost/)
pub fn boost(set: Bool) {
  case set {
    True -> attribute("hx-boost", "true")
    False -> attribute("hx-boost", "false")
  }
}

/// Adds values to be submitted with the request.
///
/// [Official Documentation](https://htmx.org/attributes/hx-vals/)
pub fn vals(json: json.Json, compute_value: Bool) {
  case compute_value {
    True -> attribute("hx-vals", "js:" <> json.to_string(json))
    False -> attribute("hx-vals", json.to_string(json))
  }
}

/// Disables HTMX processing for an element and its children.
///
/// [Official Documentation](https://htmx.org/attributes/hx-disable/)
pub fn disable() {
  attribute("hx-disable", "")
}

/// Disables elements during AJAX requests.
///
/// [Official Documentation](https://htmx.org/attributes/hx-disabled-elt/)
///
/// ## Examples
/// ```gleam
/// // Disable specific buttons
/// hx.disable_elt([hx.Selector("button")])
///
/// // Disable multiple element types
/// hx.disable_elt([
///   hx.Selector("input[type='submit']"),
///   hx.Selector("button")
/// ])
/// ```
pub fn disable_elt(extended_css_selectors: List(Selector)) {
  let selectors =
    extended_css_selectors
    |> list.map(selector_to_string)
    |> string.join(",")
  attribute("hx-disable-elt", selectors)
}

/// Controls which attributes are not inherited from parent elements.
///
/// [Official Documentation](https://htmx.org/attributes/hx-disinherit/)
pub fn disinherit(attributes: List(String)) {
  let attributes = attributes |> string.join(" ")
  attribute("hx-disinherit", attributes)
}

/// Prevents inheritance of all HTMX attributes from ancestors.
///
/// [Official Documentation](https://htmx.org/attributes/hx-disinherit/)
pub fn disinherit_all() {
  attribute("hx-disinherit", "*")
}

/// Sets the encoding type for the request (e.g., "multipart/form-data").
///
/// [Official Documentation](https://htmx.org/attributes/hx-encoding/)
pub fn encoding(encoding: String) {
  attribute("hx-encoding", encoding)
}

/// Enables HTMX extensions for an element.
///
/// [Official Documentation](https://htmx.org/attributes/hx-ext/)
pub fn ext(ext: List(String)) {
  let ext = ext |> string.join(",")
  attribute("hx-ext", ext)
}

/// Adds custom headers to the AJAX request.
///
/// [Official Documentation](https://htmx.org/attributes/hx-headers/)
pub fn headers(headers: json.Json, compute_value: Bool) {
  case compute_value {
    True -> attribute("hx-headers", "js:" <> json.to_string(headers))
    False -> attribute("hx-headers", json.to_string(headers))
  }
}

/// Controls if requests from this element update browser history.
///
/// [Official Documentation](https://htmx.org/attributes/hx-history/)
pub fn history(should_be_saved: Bool) {
  case should_be_saved {
    True -> attribute("hx-history", "true")
    False -> attribute("hx-history", "false")
  }
}

/// Marks the element to snapshot for history restoration.
///
/// [Official Documentation](https://htmx.org/attributes/hx-history-elt/)
pub fn history_elt() {
  attribute("hx-history-elt", "")
}

/// Includes additional element values in the request.
///
/// [Official Documentation](https://htmx.org/attributes/hx-include/)
pub fn include(extended_css_selector: Selector) {
  attribute("hx-include", selector_to_string(extended_css_selector))
}

/// Explicitly inherits specific attributes from parent elements.
///
/// [Official Documentation](https://htmx.org/attributes/hx-inherit/)
pub fn inherit(attributes: List(String)) {
  let attributes = attributes |> string.join(" ")
  attribute("hx-inherit", attributes)
}

/// Inherits all HTMX attributes from parent elements.
///
/// [Official Documentation](https://htmx.org/attributes/hx-inherit/)
pub fn inherit_all() {
  attribute("hx-inherit", "*")
}

/// Filters which parameters are included in the request.
///
/// [Official Documentation](https://htmx.org/attributes/hx-params/)
pub fn params(params: String) {
  attribute("hx-params", params)
}

/// Preserves element state between requests (e.g., iframes, videos).
///
/// [Official Documentation](https://htmx.org/attributes/hx-preserve/)
pub fn preserve() {
  attribute("hx-preserve", "")
}

/// Shows an input prompt before submitting the request.
///
/// [Official Documentation](https://htmx.org/attributes/hx-prompt/)
pub fn prompt(prompt_text: String) {
  attribute("hx-prompt", prompt_text)
}

/// Replaces the current URL in the browser history.
///
/// [Official Documentation](https://htmx.org/attributes/hx-replace-url/)
pub fn replace_url() {
  attribute("hx-replace-url", "true")
}

/// Prevents URL replacement in the browser history.
///
/// [Official Documentation](https://htmx.org/attributes/hx-replace-url/)
pub fn no_replace_url() {
  attribute("hx-replace-url", "false")
}

/// Replaces the current URL with the specified URL.
///
/// [Official Documentation](https://htmx.org/attributes/hx-replace-url/)
pub fn replace_url_with(url: String) {
  attribute("hx-replace-url", url)
}

/// Configures the AJAX request (timeout, credentials, etc.).
///
/// [Official Documentation](https://htmx.org/attributes/hx-request/)
pub fn request(request: String) {
  attribute("hx-request", request)
}

/// Forces validation before making a request.
///
/// [Official Documentation](https://htmx.org/attributes/hx-validate/)
pub fn validate(bool: Bool) {
  case bool {
    True -> attribute("hx-validate", "true")
    False -> attribute("hx-validate", "false")
  }
}

/// Adds hyperscript behavior to an element using the "_" attribute.
///
/// [Official Hyperscript Documentation](https://hyperscript.org/)
pub fn hyper_script(script: String) {
  attribute("_", script)
}

/// Handles events with inline scripts on elements using the hx-on attribute.
///
/// This is an HTMX 2.x feature that allows inline event handling.
///
/// [Official Documentation](https://htmx.org/attributes/hx-on/)
///
/// ## Examples
/// ```gleam
/// hx.on("click", "alert('Clicked!')")
/// hx.on("htmx:afterSwap", "console.log('Swapped')")
/// ```
pub fn on(event_name: String, script: String) {
  attribute("hx-on:" <> event_name, script)
}

// ==== EVENT TYPES AND MODIFIERS ====

/// Event triggers with optional modifiers.
///
/// Events can be combined with modifiers like `with_delay`, `with_throttle`, etc.
///
/// [Official Event Documentation](https://htmx.org/docs/#events)
pub opaque type Event {
  Event(event: String, modifiers: List(EventModifier))
}

/// Modifiers that change event behavior.
///
/// [Official Trigger Modifiers](https://htmx.org/attributes/hx-trigger/#standard-event-modifiers)
pub opaque type EventModifier {
  Once
  Changed
  Delay(duration.Duration)
  Throttle(duration.Duration)
  From(extended_css_selector: Selector)
  Target(css_selector: String)
  Consume
  QueueEvent(Option(Queue))
}

// ==== COMMON DOM EVENTS ====

/// Creates a load event that fires when the element loads.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Window/load_event)
pub fn load() -> Event {
  Event(event: "load", modifiers: [])
}

/// Creates a DOMContentLoaded event that fires when the initial HTML document is loaded.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Document/DOMContentLoaded_event)
pub fn dom_content_loaded() -> Event {
  Event(event: "DOMContentLoaded", modifiers: [])
}

/// Creates a click event.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Element/click_event)
pub fn click() -> Event {
  Event(event: "click", modifiers: [])
}

/// Creates a change event (fires when an input value changes).
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/change_event)
pub fn change() -> Event {
  Event(event: "change", modifiers: [])
}

/// Creates a submit event (fires when a form is submitted).
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement/submit_event)
pub fn submit() -> Event {
  Event(event: "submit", modifiers: [])
}

/// Creates a keyup event.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Element/keyup_event)
pub fn keyup() -> Event {
  Event(event: "keyup", modifiers: [])
}

/// Creates a keydown event.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Element/keydown_event)
pub fn keydown() -> Event {
  Event(event: "keydown", modifiers: [])
}

/// Creates a focus event.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Element/focus_event)
pub fn focus() -> Event {
  Event(event: "focus", modifiers: [])
}

/// Creates a blur event.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Element/blur_event)
pub fn blur() -> Event {
  Event(event: "blur", modifiers: [])
}

/// Creates a mouseover event.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Element/mouseover_event)
pub fn mouseover() -> Event {
  Event(event: "mouseover", modifiers: [])
}

/// Creates a mouseout event.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Element/mouseout_event)
pub fn mouseout() -> Event {
  Event(event: "mouseout", modifiers: [])
}

/// Creates an input event (fires on every character typed).
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/input_event)
pub fn input() -> Event {
  Event(event: "input", modifiers: [])
}

/// Creates a scroll event.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Element/scroll_event)
pub fn scroll() -> Event {
  Event(event: "scroll", modifiers: [])
}

/// Creates a resize event.
///
/// [MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/Window/resize_event)
pub fn resize() -> Event {
  Event(event: "resize", modifiers: [])
}

// ==== HTMX-SPECIFIC EVENTS ====

/// Triggered before an AJAX request is made.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeRequest)
pub fn htmx_before_request() -> Event {
  Event(event: "htmx:beforeRequest", modifiers: [])
}

/// Triggered after an AJAX request completes.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:afterRequest)
pub fn htmx_after_request() -> Event {
  Event(event: "htmx:afterRequest", modifiers: [])
}

/// Triggered before content is swapped into the DOM.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeSwap)
pub fn htmx_before_swap() -> Event {
  Event(event: "htmx:beforeSwap", modifiers: [])
}

/// Triggered after content is swapped into the DOM.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:afterSwap)
pub fn htmx_after_swap() -> Event {
  Event(event: "htmx:afterSwap", modifiers: [])
}

/// Triggered before the settling phase begins.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeSettle)
pub fn htmx_before_settle() -> Event {
  Event(event: "htmx:beforeSettle", modifiers: [])
}

/// Triggered after the settling phase completes.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:afterSettle)
pub fn htmx_after_settle() -> Event {
  Event(event: "htmx:afterSettle", modifiers: [])
}

/// Triggered when new content is loaded into the DOM.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:load)
pub fn htmx_load() -> Event {
  Event(event: "htmx:load", modifiers: [])
}

/// Triggered before a request is configured.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:configRequest)
pub fn htmx_config_request() -> Event {
  Event(event: "htmx:configRequest", modifiers: [])
}

/// Triggered when an HTTP error response is received.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:responseError)
pub fn htmx_response_error() -> Event {
  Event(event: "htmx:responseError", modifiers: [])
}

/// Triggered when a network error occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:sendError)
pub fn htmx_send_error() -> Event {
  Event(event: "htmx:sendError", modifiers: [])
}

/// Triggered when a request times out.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:timeout)
pub fn htmx_timeout() -> Event {
  Event(event: "htmx:timeout", modifiers: [])
}

/// Triggered before every request trigger, allowing cancellation or async confirmation.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:confirm)
pub fn htmx_confirm() -> Event {
  Event(event: "htmx:confirm", modifiers: [])
}

/// Triggered right before sending the request.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeSend)
pub fn htmx_before_send() -> Event {
  Event(event: "htmx:beforeSend", modifiers: [])
}

/// Validates the URL before making the request.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:validateUrl)
pub fn htmx_validate_url() -> Event {
  Event(event: "htmx:validateUrl", modifiers: [])
}

/// Triggered before any response processing.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeOnLoad)
pub fn htmx_before_on_load() -> Event {
  Event(event: "htmx:beforeOnLoad", modifiers: [])
}

/// Triggered after an AJAX onload has finished.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:afterOnLoad)
pub fn htmx_after_on_load() -> Event {
  Event(event: "htmx:afterOnLoad", modifiers: [])
}

/// Triggered when a request is aborted.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:sendAbort)
pub fn htmx_send_abort() -> Event {
  Event(event: "htmx:sendAbort", modifiers: [])
}

/// Listener event to cancel ongoing requests.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:abort)
pub fn htmx_abort() -> Event {
  Event(event: "htmx:abort", modifiers: [])
}

/// Triggered before validation runs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:validation:validate)
pub fn htmx_validation_validate() -> Event {
  Event(event: "htmx:validation:validate", modifiers: [])
}

/// Triggered when validation fails.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:validation:failed)
pub fn htmx_validation_failed() -> Event {
  Event(event: "htmx:validation:failed", modifiers: [])
}

/// Triggered when validation is halted.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:validation:halted)
pub fn htmx_validation_halted() -> Event {
  Event(event: "htmx:validation:halted", modifiers: [])
}

/// Triggered when an XHR request is aborted.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:xhr:abort)
pub fn htmx_xhr_abort() -> Event {
  Event(event: "htmx:xhr:abort", modifiers: [])
}

/// Triggered when an XHR request ends.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:xhr:loadend)
pub fn htmx_xhr_loadend() -> Event {
  Event(event: "htmx:xhr:loadend", modifiers: [])
}

/// Triggered when an XHR request starts.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:xhr:loadstart)
pub fn htmx_xhr_loadstart() -> Event {
  Event(event: "htmx:xhr:loadstart", modifiers: [])
}

/// Triggered during XHR request progress.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:xhr:progress)
pub fn htmx_xhr_progress() -> Event {
  Event(event: "htmx:xhr:progress", modifiers: [])
}

/// Triggered before processing a DOM node.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeProcessNode)
pub fn htmx_before_process_node() -> Event {
  Event(event: "htmx:beforeProcessNode", modifiers: [])
}

/// Triggered after processing a DOM node.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:afterProcessNode)
pub fn htmx_after_process_node() -> Event {
  Event(event: "htmx:afterProcessNode", modifiers: [])
}

/// Triggered before cleaning up an element.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeCleanupElement)
pub fn htmx_before_cleanup_element() -> Event {
  Event(event: "htmx:beforeCleanupElement", modifiers: [])
}

/// Triggered before View Transition API wraps a swap.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeTransition)
pub fn htmx_before_transition() -> Event {
  Event(event: "htmx:beforeTransition", modifiers: [])
}

/// Triggered when a trigger is activated.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:trigger)
pub fn htmx_trigger() -> Event {
  Event(event: "htmx:trigger", modifiers: [])
}

/// Triggered before an out-of-band swap.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:oobBeforeSwap)
pub fn htmx_oob_before_swap() -> Event {
  Event(event: "htmx:oobBeforeSwap", modifiers: [])
}

/// Triggered after an out-of-band swap.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:oobAfterSwap)
pub fn htmx_oob_after_swap() -> Event {
  Event(event: "htmx:oobAfterSwap", modifiers: [])
}

/// Triggered when an OOB swap target is not found.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:oobErrorNoTarget)
pub fn htmx_oob_error_no_target() -> Event {
  Event(event: "htmx:oobErrorNoTarget", modifiers: [])
}

/// Triggered when an error occurs during swap.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:swapError)
pub fn htmx_swap_error() -> Event {
  Event(event: "htmx:swapError", modifiers: [])
}

/// Triggered on general errors.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:error)
pub fn htmx_error() -> Event {
  Event(event: "htmx:error", modifiers: [])
}

/// Triggered when a history item is created.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:historyItemCreated)
pub fn htmx_history_item_created() -> Event {
  Event(event: "htmx:historyItemCreated", modifiers: [])
}

/// Triggered when a history cache error occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:historyCacheError)
pub fn htmx_history_cache_error() -> Event {
  Event(event: "htmx:historyCacheError", modifiers: [])
}

/// Triggered before a history save occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeHistorySave)
pub fn htmx_before_history_save() -> Event {
  Event(event: "htmx:beforeHistorySave", modifiers: [])
}

/// Triggered before a history update occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:beforeHistoryUpdate)
pub fn htmx_before_history_update() -> Event {
  Event(event: "htmx:beforeHistoryUpdate", modifiers: [])
}

/// Triggered when history is restored.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:historyRestore)
pub fn htmx_history_restore() -> Event {
  Event(event: "htmx:historyRestore", modifiers: [])
}

/// Triggered when an element is pushed into history.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:pushedIntoHistory)
pub fn htmx_pushed_into_history() -> Event {
  Event(event: "htmx:pushedIntoHistory", modifiers: [])
}

/// Triggered when an element is replaced in history.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:replacedInHistory)
pub fn htmx_replaced_in_history() -> Event {
  Event(event: "htmx:replacedInHistory", modifiers: [])
}

/// Triggered when the page is restored from history.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:restored)
pub fn htmx_restored() -> Event {
  Event(event: "htmx:restored", modifiers: [])
}

/// Triggered when a history cache hit occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:historyCacheHit)
pub fn htmx_history_cache_hit() -> Event {
  Event(event: "htmx:historyCacheHit", modifiers: [])
}

/// Triggered when a history cache miss occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:historyCacheMiss)
pub fn htmx_history_cache_miss() -> Event {
  Event(event: "htmx:historyCacheMiss", modifiers: [])
}

/// Triggered when loading after a history cache miss.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:historyCacheMissLoad)
pub fn htmx_history_cache_miss_load() -> Event {
  Event(event: "htmx:historyCacheMissLoad", modifiers: [])
}

/// Triggered when a history cache miss load error occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:historyCacheMissLoadError)
pub fn htmx_history_cache_miss_load_error() -> Event {
  Event(event: "htmx:historyCacheMissLoadError", modifiers: [])
}

/// Triggered when an event filter error occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:eventFilter:error)
pub fn htmx_event_filter_error() -> Event {
  Event(event: "htmx:eventFilter:error", modifiers: [])
}

/// Triggered when a syntax error occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:syntax:error)
pub fn htmx_syntax_error() -> Event {
  Event(event: "htmx:syntax:error", modifiers: [])
}

/// Triggered when a bad response URL is encountered.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:badResponseUrl)
pub fn htmx_bad_response_url() -> Event {
  Event(event: "htmx:badResponseUrl", modifiers: [])
}

/// Triggered when an invalid path is encountered.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:invalidPath)
pub fn htmx_invalid_path() -> Event {
  Event(event: "htmx:invalidPath", modifiers: [])
}

/// Triggered when an onload error occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:onLoadError)
pub fn htmx_on_load_error() -> Event {
  Event(event: "htmx:onLoadError", modifiers: [])
}

/// Triggered when a target error occurs.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:targetError)
pub fn htmx_target_error() -> Event {
  Event(event: "htmx:targetError", modifiers: [])
}

/// Triggered when eval is disallowed.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:evalDisallowedError)
pub fn htmx_eval_disallowed_error() -> Event {
  Event(event: "htmx:evalDisallowedError", modifiers: [])
}

/// Triggered when a prompt is shown.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:prompt)
pub fn htmx_prompt() -> Event {
  Event(event: "htmx:prompt", modifiers: [])
}

/// Triggered during session storage test.
///
/// [Official Events Reference](https://htmx.org/events/#htmx:sessionStorageTest)
pub fn htmx_session_storage_test() -> Event {
  Event(event: "htmx:sessionStorageTest", modifiers: [])
}

// ==== INTERSECT AND VIEWPORT EVENTS ====

/// Configuration options for the intersect event.
///
/// [Official Intersect Documentation](https://htmx.org/attributes/hx-trigger/#non-standard-events)
pub type IntersectConfig {
  /// Specify the root element for intersection observation
  Root(selector: String)
  /// Intersection threshold (0.0 to 1.0)
  Threshold(value: Float)
}

fn intersect_config_to_string(config: IntersectConfig) -> String {
  case config {
    Root(selector) -> "root:" <> selector
    Threshold(value) -> "threshold:" <> float.to_string(value)
  }
}

/// Creates a revealed event that triggers when the element is scrolled into the viewport.
///
/// [Official Revealed Documentation](https://htmx.org/docs/#revealed)
pub fn revealed() -> Event {
  Event(event: "revealed", modifiers: [])
}

/// Creates an intersect event that triggers when the element enters the viewport.
///
/// Supports configuration options for root element, threshold, and root margin.
///
/// [Official Intersect Documentation](https://htmx.org/docs/#intersect)
///
/// ## Examples
/// ```gleam
/// // Basic intersect
/// hx.intersect([])
///
/// // With threshold
/// hx.intersect([hx.Threshold(0.5)])
///
/// // With root element and threshold
/// hx.intersect([hx.Root("#container"), hx.Threshold(0.75)])
/// ```
pub fn intersect(config: List(IntersectConfig)) -> Event {
  case config {
    [] -> Event(event: "intersect", modifiers: [])
    configs -> {
      let config_str =
        configs
        |> list.map(intersect_config_to_string)
        |> string.join(" ")
      Event(event: "intersect " <> config_str, modifiers: [])
    }
  }
}

/// Creates an intersect event that fires only once when entering the viewport.
///
/// [Official Intersect Documentation](https://htmx.org/docs/#intersect)
///
/// ## Examples
/// ```gleam
/// // Basic intersect once
/// hx.intersect_once([])
///
/// // With threshold, fires once
/// hx.intersect_once([hx.Threshold(0.5)])
/// ```
pub fn intersect_once(config: List(IntersectConfig)) -> Event {
  case config {
    [] -> Event(event: "intersect", modifiers: [Once])
    configs -> {
      let config_str =
        configs
        |> list.map(intersect_config_to_string)
        |> string.join(" ")
      Event(event: "intersect " <> config_str, modifiers: [Once])
    }
  }
}

// ==== EVENT HELPER FUNCTIONS ====

/// Creates a custom event with the given name.
pub fn custom(event_name: String) -> Event {
  Event(event: event_name, modifiers: [])
}

/// Adds a delay before the event triggers.
///
/// [Official Trigger Modifiers](https://htmx.org/attributes/hx-trigger/#standard-event-modifiers)
pub fn with_delay(event: Event, timing: duration.Duration) -> Event {
  Event(event: event.event, modifiers: [Delay(timing), ..event.modifiers])
}

/// Throttles the event to fire at most once per duration.
///
/// [Official Trigger Modifiers](https://htmx.org/attributes/hx-trigger/#standard-event-modifiers)
pub fn with_throttle(event: Event, timing: duration.Duration) -> Event {
  Event(event: event.event, modifiers: [Throttle(timing), ..event.modifiers])
}

/// Makes the event fire only once.
///
/// [Official Trigger Modifiers](https://htmx.org/attributes/hx-trigger/#standard-event-modifiers)
pub fn with_once(event: Event) -> Event {
  Event(event: event.event, modifiers: [Once, ..event.modifiers])
}

/// Only triggers if the element's value has changed.
///
/// [Official Trigger Modifiers](https://htmx.org/attributes/hx-trigger/#standard-event-modifiers)
pub fn with_changed(event: Event) -> Event {
  Event(event: event.event, modifiers: [Changed, ..event.modifiers])
}

/// Listens for the event on a different element.
///
/// [Official Trigger Modifiers](https://htmx.org/attributes/hx-trigger/#standard-event-modifiers)
pub fn with_from(event: Event, extended_css_selector: Selector) -> Event {
  Event(event: event.event, modifiers: [
    From(extended_css_selector),
    ..event.modifiers
  ])
}

/// Filters the event to only trigger when it targets a specific element.
///
/// [Official Trigger Modifiers](https://htmx.org/attributes/hx-trigger/#standard-event-modifiers)
pub fn with_target(event: Event, css_selector: String) -> Event {
  Event(event: event.event, modifiers: [Target(css_selector), ..event.modifiers])
}

/// Prevents the event from bubbling up the DOM.
///
/// [Official Trigger Modifiers](https://htmx.org/attributes/hx-trigger/#standard-event-modifiers)
pub fn with_consume(event: Event) -> Event {
  Event(event: event.event, modifiers: [Consume, ..event.modifiers])
}

/// Queues the event with a specific strategy.
///
/// [Official Trigger Modifiers](https://htmx.org/attributes/hx-trigger/#standard-event-modifiers)
pub fn with_queue(event: Event, queue: Option(Queue)) -> Event {
  Event(event: event.event, modifiers: [QueueEvent(queue), ..event.modifiers])
}

fn modifier_to_string(event_modifier event_modifier: EventModifier) {
  case event_modifier {
    Once -> "once"
    Changed -> "changed"
    Delay(t) -> "delay:" <> duration_to_string(t)
    Throttle(t) -> "throttle:" <> duration_to_string(t)
    From(extended_css_selector) ->
      "from:" <> selector_to_string(extended_css_selector)
    Target(css_selector) -> "target:" <> css_selector
    Consume -> "consume"
    QueueEvent(Some(queue)) -> "queue:" <> queue_to_string(queue)
    QueueEvent(None) -> "queue:none"
  }
}

fn event_to_string(event: Event) {
  event.event
  <> list.map(event.modifiers, fn(e) { " " <> modifier_to_string(e) })
  |> string.join("")
}

// ==== QUEUE ====

/// Queue behavior for synchronized requests.
///
/// Used with `hx.sync` to control request queuing.
///
/// [Official Sync Documentation](https://htmx.org/attributes/hx-sync/)
pub type Queue {
  /// Process the first request, ignore subsequent
  First
  /// Process the last request, ignore previous
  Last
  /// Process all requests
  All
}

fn queue_to_string(queue: Queue) -> String {
  case queue {
    First -> "first"
    Last -> "last"
    All -> "all"
  }
}

/// Extended CSS selectors for targeting elements.
///
/// HTMX extends standard CSS selectors with additional keywords for more flexible targeting.
///
/// [Official Extended CSS Selectors Documentation](https://htmx.org/docs/#extended-css-selectors)
pub type Selector {
  /// Standard CSS selector (e.g., "#id", ".class", "div > p")
  Selector(selector: String)
  /// Target the document
  Document
  /// Target the window
  Window
  /// Find the closest ancestor matching the selector
  Closest(selector: String)
  /// Find the first descendant matching the selector
  Find(selector: String)
  /// Find the next sibling matching the selector
  Next(selector: String)
  /// Find the previous sibling matching the selector
  Previous(selector: String)
  /// Target the element itself
  This
}

fn selector_to_string(extended_css_selector: Selector) -> String {
  case extended_css_selector {
    Selector(css_selector) -> css_selector
    Document -> "document"
    Window -> "window"
    Closest(css_selector) -> "closest " <> css_selector
    Find(css_selector) -> "find " <> css_selector
    Next(css_selector) -> "next " <> css_selector
    Previous(css_selector) -> "previous " <> css_selector
    This -> "this"
  }
}

/// Convert a duration to an HTMX timing declaration string.
@internal
pub fn duration_to_string(d: duration.Duration) -> String {
  duration.to_milliseconds(d)
  |> int.to_string
  |> string.append("ms")
}

/// Synchronization options for coordinating AJAX requests.
///
/// Controls how multiple requests to the same element are handled.
///
/// [Official Sync Documentation](https://htmx.org/attributes/hx-sync/)
pub type Sync {
  /// Use default behavior (drop new requests if one is in flight)
  Default(Selector)
  /// Explicitly drop (ignore) new requests if one is in flight
  Drop(Selector)
  /// Drop new requests OR abort current request if a new one comes in
  Abort(Selector)
  /// Abort current request and replace it with the new one
  Replace(Selector)
  /// Queue requests with specified strategy
  Queue(Selector, Queue)
}

/// Different ways content can be swapped in the DOM.
///
/// Controls how the response content replaces existing content.
///
/// [Official Swap Documentation](https://htmx.org/attributes/hx-swap/)
pub type Swap {
  /// Replace the inner HTML of the target element
  InnerHTML
  /// Replace the entire target element
  OuterHTML
  /// Replace the text content of the target element
  TextContent
  /// Insert inside the target, before its first child
  Afterbegin
  /// Insert before the target element (as a sibling)
  Beforebegin
  /// Insert inside the target, after its last child
  Beforeend
  /// Insert after the target element (as a sibling)
  Afterend
  /// Delete the target element
  Delete
  /// Do not swap content
  SwapNone
}

/// Scroll position specification for swap modifiers.
pub type ScrollPosition {
  /// Scroll to the top
  Top
  /// Scroll to the bottom
  Bottom
}

/// Scroll target specification for swap modifiers.
pub type ScrollTarget {
  /// Scroll the swap target element
  TargetScroll(ScrollPosition)
  /// Scroll a specific element by CSS selector
  ElementScroll(selector: String, position: ScrollPosition)
  /// Scroll the window
  WindowScroll(ScrollPosition)
}

/// Show target specification for swap modifiers.
pub type ShowTarget {
  /// Show the swap target in viewport
  TargetShow(ScrollPosition)
  /// Show a specific element in viewport
  ElementShow(selector: String, position: ScrollPosition)
  /// Show in window viewport
  WindowShow(ScrollPosition)
}

/// Options for modifying swap behavior.
///
/// These modifiers can be used with `swap_with` and `swap_oob_with`.
///
/// [Official Swap Modifiers Documentation](https://htmx.org/attributes/hx-swap/#modifiers)
pub type SwapConfig {
  /// Enable/disable view transitions
  Transition(Bool)
  /// Delay before swapping content
  SwapTiming(duration.Duration)
  /// Duration to wait after swap before settling
  Settle(duration.Duration)
  /// Whether to ignore title updates from response
  IgnoreTitle(Bool)
  /// Scroll configuration
  ScrollTo(ScrollTarget)
  /// Show configuration
  Show(ShowTarget)
  /// Whether to scroll to focused element
  FocusScroll(Bool)
}

fn scroll_position_to_string(pos: ScrollPosition) -> String {
  case pos {
    Top -> "top"
    Bottom -> "bottom"
  }
}

fn scroll_target_to_string(target: ScrollTarget) -> String {
  case target {
    TargetScroll(pos) -> "scroll:" <> scroll_position_to_string(pos)
    ElementScroll(selector, pos) ->
      "scroll:" <> selector <> ":" <> scroll_position_to_string(pos)
    WindowScroll(pos) -> "scroll:window:" <> scroll_position_to_string(pos)
  }
}

fn show_target_to_string(target: ShowTarget) -> String {
  case target {
    TargetShow(pos) -> "show:" <> scroll_position_to_string(pos)
    ElementShow(selector, pos) ->
      "show:" <> selector <> ":" <> scroll_position_to_string(pos)
    WindowShow(pos) -> "show:window:" <> scroll_position_to_string(pos)
  }
}

fn swap_option_to_string(swap_option: SwapConfig) {
  case swap_option {
    Transition(True) -> "transition:true"
    Transition(False) -> "transition:false"
    SwapTiming(timing_declaration) ->
      "swap:" <> duration_to_string(timing_declaration)
    Settle(timing_declaration) ->
      "settle:" <> duration_to_string(timing_declaration)
    IgnoreTitle(True) -> "ignoreTitle:true"
    IgnoreTitle(False) -> "ignoreTitle:false"
    ScrollTo(target) -> scroll_target_to_string(target)
    Show(target) -> show_target_to_string(target)
    FocusScroll(True) -> "focus-scroll:true"
    FocusScroll(False) -> "focus-scroll:false"
  }
}

fn swap_to_string(swap: Swap) {
  case swap {
    InnerHTML -> "innerHTML"
    OuterHTML -> "outerHTML"
    TextContent -> "textContent"
    Afterbegin -> "afterbegin"
    Beforebegin -> "beforebegin"
    Beforeend -> "beforeend"
    Afterend -> "afterend"
    Delete -> "delete"
    SwapNone -> "none"
  }
}

pub fn sync_option_to_string(sync_option: Sync) -> String {
  case sync_option {
    Default(selector) -> selector_to_string(selector)
    Drop(selector) -> selector_to_string(selector) <> ":drop"
    Abort(selector) -> selector_to_string(selector) <> ":abort"
    Replace(selector) -> selector_to_string(selector) <> ":replace"
    Queue(selector, queue) ->
      selector_to_string(selector) <> ":queue " <> queue_to_string(queue)
  }
}
