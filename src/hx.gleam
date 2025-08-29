import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import hx/attribute as hx_attribute
import hx/css_selector
import hx/event
import hx/timing
import lustre/attribute.{attribute}

/// # hx-trigger
/// Specifies which events will cause a request.
/// 
/// ## Examples
/// ```gleam
/// import hx/event
/// 
/// // Single event
/// hx.trigger([event.click()])
/// 
/// // Multiple events  
/// hx.trigger([event.click(), event.keyup()])
/// 
/// // Event with modifiers
/// hx.trigger([event.with_delay(event.click(), timing.Seconds(2))])
/// ```
pub fn trigger(events: List(event.Event)) {
  let events =
    events
    |> list.map(event.to_string)
    |> string.join(", ")
  attribute("hx-trigger", events)
}

/// # hx-trigger (polling)
/// Creates a polling trigger that fires at regular intervals.
/// 
/// ## Examples
/// ```gleam
/// import hx/timing
/// 
/// // Poll every 5 seconds
/// hx.trigger_polling(timing: timing.Seconds(5), filters: None, on_load: False)
/// 
/// // Poll with filters
/// hx.trigger_polling(timing: timing.Seconds(10), filters: Some("visible"), on_load: False)
/// 
/// // Start polling immediately and on load
/// hx.trigger_polling(timing: timing.Seconds(2), filters: None, on_load: True)
/// ```
pub fn trigger_polling(
  timing timing: timing.Timing,
  filters filters: Option(String),
  on_load on_load: Bool,
) {
  case filters, on_load {
    Some(filters), False ->
      attribute(
        "hx-trigger",
        "every " <> timing.to_string(timing) <> " [" <> filters <> "]",
      )
    None, False -> attribute("hx-trigger", "every " <> timing.to_string(timing))
    None, True ->
      attribute("hx-trigger", "load every " <> timing.to_string(timing))
    Some(filters), True ->
      attribute(
        "hx-trigger",
        "load every " <> timing.to_string(timing) <> " [" <> filters <> "]",
      )
  }
}

/// # hx-get
/// Issues a GET request to the given URL when the element is triggered.
pub fn get(url url: String) {
  attribute("hx-get", url)
}

/// # hx-post
/// Issues a POST request to the given URL when the element is triggered.
pub fn post(url url: String) {
  attribute("hx-post", url)
}

/// # hx-put
/// Issues a PUT request to the given URL when the element is triggered.
pub fn put(url url: String) {
  attribute("hx-put", url)
}

/// # hx-patch
/// Issues a PATCH request to the given URL when the element is triggered.
pub fn patch(url url: String) {
  attribute("hx-patch", url)
}

/// # hx-delete
/// Issues a DELETE request to the given URL when the element is triggered.
pub fn delete(url url: String) {
  attribute("hx-delete", url)
}

/// # hx-indicator
/// Shows elements during the AJAX request.
pub fn indicator(css_selector_or_closest css_selector_or_closest: String) {
  attribute("hx-indicator", css_selector_or_closest)
}

/// # hx-target
/// Specifies the target element to swap content into.
/// 
/// ## Examples
/// ```gleam
/// import hx/css_selector
/// 
/// // Target specific element
/// hx.target(css_selector.CssSelector("#results"))
/// 
/// // Target parent element
/// hx.target(css_selector.Closest(".card"))
/// 
/// // Target the element itself
/// hx.target(css_selector.This)
/// ```
pub fn target(
  extended_css_selector extended_css_selector: css_selector.Selector,
) {
  attribute("hx-target", css_selector.to_string(extended_css_selector))
}

/// # hx-swap
/// Controls how content is swapped into the DOM.
/// 
/// ## Examples
/// ```gleam
/// import hx/attribute
/// 
/// // Basic swap strategies
/// hx.swap(attribute.InnerHTML)
/// hx.swap(attribute.OuterHTML)
/// hx.swap(attribute.Afterend)
/// ```
pub fn swap(swap swap: hx_attribute.Swap) {
  swap
  |> hx_attribute.swap_to_string
  |> attribute("hx-swap", _)
}

/// # hx-swap (with config)
/// Controls how content is swapped into the DOM with additional configuration options.
/// 
/// ## Examples
/// ```gleam
/// import hx/attribute
/// import hx/timing
/// 
/// // Swap with transition
/// hx.swap_with(attribute.InnerHTML, attribute.Transition(True))
/// 
/// // Swap with timing
/// hx.swap_with(attribute.OuterHTML, attribute.SwapTiming(timing.Milliseconds(500)))
/// ```
pub fn swap_with(
  swap swap: hx_attribute.Swap,
  config config: hx_attribute.SwapConfig,
) {
  swap
  |> hx_attribute.swap_to_string
  |> string.append(" " <> hx_attribute.swap_option_to_string(config))
  |> attribute("hx-swap", _)
}

/// # hx-swap-oob
/// Allows you to specify that some content in a response should be swapped "out of band".
pub fn swap_oob(
  swap swap: hx_attribute.Swap,
  css_selector css_selector: Option(String),
) {
  case css_selector {
    Some(css_selector) ->
      swap
      |> hx_attribute.swap_to_string
      |> string.append("," <> css_selector)
      |> attribute("hx-swap-oob", _)
    None ->
      swap
      |> hx_attribute.swap_to_string
      |> attribute("hx-swap-oob", _)
  }
}

/// # hx-swap-oob
/// Allows you to specify that some content in a response should be swapped "out of band".
pub fn swap_oob_with(
  swap swap: hx_attribute.Swap,
  css_selector css_selector: Option(String),
  config modifier: hx_attribute.SwapConfig,
) {
  case css_selector {
    Some(css_selector) -> {
      swap
      |> hx_attribute.swap_to_string
      |> string.append("," <> css_selector)
      |> string.append(" " <> hx_attribute.swap_option_to_string(modifier))
      |> attribute("hx-swap-oob", _)
    }
    None -> {
      swap
      |> hx_attribute.swap_to_string
      |> string.append(" " <> hx_attribute.swap_option_to_string(modifier))
      |> attribute("hx-swap-oob", _)
    }
  }
}

/// # hx-sync
/// Synchronizes AJAX requests with other elements.
/// 
/// ## Examples
/// ```gleam
/// import hx/attribute
/// import hx/queue
/// 
/// // Drop conflicting requests
/// hx.sync([attribute.Drop("#form")])
/// 
/// // Use queue with priority
/// hx.sync([attribute.SyncQueue("#queue", queue.First)])
/// ```
pub fn sync(syncronize_on: List(hx_attribute.Sync)) {
  attribute(
    "hx-sync",
    list.map(syncronize_on, hx_attribute.sync_option_to_string)
      |> string.join(" "),
  )
}

/// # hx-select
/// Selects a subset of the server response to process.
pub fn select(css_selector: String) {
  attribute("hx-select", css_selector)
}

/// # hx-select-oob
/// Selects content from a response to be swapped in to the current page.
pub fn select_oob(
  css_selector: String,
  swap_strategies: List(hx_attribute.Swap),
) {
  let swap_strategies =
    swap_strategies
    |> list.map(hx_attribute.swap_to_string)
    |> string.join(",")
  case swap_strategies {
    "" -> attribute("hx-select", css_selector)
    _ -> attribute("hx-select", css_selector <> ":" <> swap_strategies)
  }
}

/// # hx-push-url
/// Pushes a URL into the browser's location bar.
pub fn push_url(bool: Bool) {
  case bool {
    True -> attribute("hx-push-url", "true")
    False -> attribute("hx-push-url", "false")
  }
}

/// # hx-confirm
/// Shows a confirmation dialog before making a request.
pub fn confirm(confirm_text: String) {
  attribute("hx-confirm", confirm_text)
}

/// # hx-boost
/// Makes regular links and forms use AJAX for navigation.
pub fn boost(set: Bool) {
  case set {
    True -> attribute("hx-boost", "true")
    False -> attribute("hx-boost", "false")
  }
}

/// # hx-vals
/// Sets values to be included in requests.
pub fn vals(json: json.Json, compute_value: Bool) {
  case compute_value {
    True -> attribute("hx-vals", "js:" <> json.to_string(json))
    False -> attribute("hx-vals", json.to_string(json))
  }
}

/// # hx-disable
/// Disables HTMX processing for a given element.
pub fn disable() {
  attribute("hx-disable", "")
}

/// # hx-disable-elt
/// Disables elements during requests.
/// 
/// ## Examples
/// ```gleam
/// import hx/css_selector
/// 
/// // Disable specific buttons
/// hx.disable_elt([css_selector.CssSelector("button")])
/// 
/// // Disable multiple element types
/// hx.disable_elt([
///   css_selector.CssSelector("input[type='submit']"), 
///   css_selector.CssSelector("button")
/// ])
/// ```
pub fn disable_elt(extended_css_selectors: List(css_selector.Selector)) {
  let selectors =
    extended_css_selectors
    |> list.map(css_selector.to_string)
    |> string.join(",")
  attribute("hx-disable-elt", selectors)
}

/// # hx-disinherit
/// Controls which attributes are inherited from ancestor elements.
pub fn disinherit(attributes: List(String)) {
  let attributes = attributes |> string.join(" ")
  attribute("hx-disinherit", attributes)
}

/// # hx-disinherit (all attributes)
/// Prevents inheritance of all HTMX attributes from ancestor elements.
pub fn disinherit_all() {
  attribute("hx-disinherit", "*")
}

/// # hx-encoding
/// Sets the encoding type for the request.
pub fn encoding(encoding: String) {
  attribute("hx-encoding", encoding)
}

/// # hx-ext
/// Includes one or more HTMX extensions for an element.
pub fn ext(ext: List(String)) {
  let ext = ext |> string.join(",")
  attribute("hx-ext", ext)
}

/// # hx-headers
/// Adds custom headers to AJAX requests.
pub fn headers(headers: json.Json, compute_value: Bool) {
  case compute_value {
    True -> attribute("hx-headers", "js:" <> json.to_string(headers))
    False -> attribute("hx-headers", json.to_string(headers))
  }
}

/// # hx-history
/// Controls if the element should be included in the browser history.
pub fn history(should_be_saved: Bool) {
  case should_be_saved {
    True -> attribute("hx-history", "true")
    False -> attribute("hx-history", "false")
  }
}

/// # hx-history-elt
/// Marks the element that should be included in the browser history.
pub fn history_elt() {
  attribute("hx-history-elt", "")
}

/// # hx-include
/// Includes additional elements in the AJAX request.
pub fn include(extended_css_selector: css_selector.Selector) {
  attribute("hx-include", css_selector.to_string(extended_css_selector))
}

/// # hx-inherit
/// Explicitly specifies which attributes to inherit from ancestors.
pub fn inherit(attributes: List(String)) {
  let attributes = attributes |> string.join(" ")
  attribute("hx-inherit", attributes)
}

/// # hx-inherit (all attributes)
/// Explicitly inherits all attributes from ancestors.
pub fn inherit_all() {
  attribute("hx-inherit", "*")
}

/// # hx-params
/// Controls which parameters are submitted with a request.
pub fn params(params: String) {
  attribute("hx-params", params)
}

/// # hx-preserve
/// Preserves an element's state between requests.
pub fn preserve() {
  attribute("hx-preserve", "")
}

/// # hx-prompt
/// Displays a prompt before submitting a request.
pub fn prompt(prompt_text: String) {
  attribute("hx-prompt", prompt_text)
}

/// # hx-replace-url (enable)
/// Replaces the current URL after the request completes.
pub fn replace_url() {
  attribute("hx-replace", "true")
}

/// # hx-replace-url (disable)
/// Disables URL replacement for the request.
pub fn no_replace_url() {
  attribute("hx-replace", "false")
}

/// # hx-replace-url (with URL)
/// Replaces the current URL with a specified one.
pub fn replace_url_with(url: String) {
  attribute("hx-replace", url)
}

/// # hx-request
/// Configures various aspects of the AJAX request.
pub fn request(request: String) {
  attribute("hx-request", request)
}

/// # hx-validate
/// Controls whether form validation should occur before a request.
pub fn validate(bool: Bool) {
  case bool {
    True -> attribute("hx-validate", "true")
    False -> attribute("hx-validate", "false")
  }
}

/// # Hyperscript integration (_)
/// Adds hyperscript to an element using the "_" attribute.
pub fn hyper_script(script: String) {
  attribute("_", script)
}
