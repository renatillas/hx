//// HTMX Response Headers
////
//// This module provides functions for setting HTMX-specific HTTP response headers.
//// These headers allow the server to control HTMX behavior on the client-side, enabling
//// powerful server-driven interactions without writing JavaScript.
////
//// ## Framework Integration
////
//// This module is framework-agnostic and returns standard `#(String, String)` tuples
//// that can be used with any Gleam web framework:
////
//// ### Wisp
//// ```gleam
//// import hx/hx_header
//// import wisp
////
//// pub fn handler(req) {
////   let #(name, value) = hx_header.trigger([
////     hx_header.SimpleTrigger("reload")
////   ])
////
////   wisp.ok()
////   |> wisp.set_header(name, value)
////   |> wisp.html_body("<div>Updated</div>")
//// }
//// ```
////
//// ### gleam_http
//// ```gleam
//// import hx/hx_header
//// import gleam/http/response as http_response
////
//// pub fn handler(req) {
////   let #(name, value) = hx_header.redirect("/login")
////
////   http_response.new(200)
////   |> http_response.set_header(name, value)
////   |> http_response.set_body("<div>Redirecting...</div>")
//// }
//// ```
////
//// ## Response Header Reference
////
//// For complete documentation of HTMX response headers, see:
//// - [HTMX Response Headers](https://htmx.org/reference/#response_headers)
//// - [HX-Trigger Documentation](https://htmx.org/headers/hx-trigger/)
//// - [HX-Location Documentation](https://htmx.org/headers/hx-location/)

import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

/// Configuration for HX-Location header with client-side redirect options.
///
/// This type represents all the options available for the HX-Location header,
/// which performs a client-side redirect using HTMX navigation.
///
/// Use the builder pattern to construct this type:
/// ```gleam
/// let config =
///   hx_header.location_config("/dashboard")
///   |> hx_header.target("#main")
///   |> hx_header.swap("innerHTML")
/// ```
pub type LocationConfig {
  LocationConfig(
    path: String,
    source: Option(String),
    event: Option(String),
    target: Option(String),
    swap: Option(String),
    values: Option(json.Json),
  )
}

/// Trigger event for HX-Trigger headers.
///
/// HTMX supports two types of trigger events:
/// - SimpleTrigger: Just an event name with no additional data
/// - DetailedTrigger: An event name with a JSON details payload
pub type TriggerEvent {
  /// Simple event name with no additional data
  SimpleTrigger(name: String)
  /// Event with JSON details payload
  DetailedTrigger(name: String, details: json.Json)
}

// ==== SIMPLE RESPONSE HEADERS ====

/// Returns HX-Redirect header for a full page redirect.
///
/// This will cause the browser to perform a full page reload to the specified URL,
/// replacing the current page entirely.
///
/// [Official Documentation](https://htmx.org/reference/#response_headers)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.redirect("/login")
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn redirect(url: String) -> #(String, String) {
  #("HX-Redirect", url)
}

/// Returns HX-Refresh header to refresh the page.
///
/// This will cause the client to perform a full page refresh.
///
/// [Official Documentation](https://htmx.org/reference/#response_headers)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.refresh()
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn refresh() -> #(String, String) {
  #("HX-Refresh", "true")
}

/// Returns HX-Push-Url header to push a URL into the browser history.
///
/// This updates the browser's address bar without performing a full page reload.
///
/// [Official Documentation](https://htmx.org/reference/#response_headers)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.push_url("/new-path")
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn push_url(url: String) -> #(String, String) {
  #("HX-Push-Url", url)
}

/// Returns HX-Replace-Url header to replace the current URL in browser history.
///
/// This updates the browser's address bar by replacing the current history entry.
///
/// [Official Documentation](https://htmx.org/reference/#response_headers)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.replace_url("/updated-path")
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn replace_url(url: String) -> #(String, String) {
  #("HX-Replace-Url", url)
}

/// Returns HX-Reswap header to change the swap strategy.
///
/// This overrides the swap strategy specified on the element.
/// Valid values include: innerHTML, outerHTML, beforebegin, afterbegin, beforeend, afterend, delete, none.
///
/// [Official Documentation](https://htmx.org/reference/#response_headers)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.reswap("outerHTML")
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn reswap(swap: String) -> #(String, String) {
  #("HX-Reswap", swap)
}

/// Returns HX-Retarget header to change the target element.
///
/// This overrides the target element specified on the original element.
///
/// [Official Documentation](https://htmx.org/reference/#response_headers)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.retarget("#different-element")
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn retarget(selector: String) -> #(String, String) {
  #("HX-Retarget", selector)
}

/// Returns HX-Reselect header to change the selected content.
///
/// This allows you to choose a different part of the response to swap in.
///
/// [Official Documentation](https://htmx.org/reference/#response_headers)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.reselect("#content")
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn reselect(selector: String) -> #(String, String) {
  #("HX-Reselect", selector)
}

// ==== LOCATION HEADERS ====

/// Returns HX-Location header for a simple client-side redirect.
///
/// This performs a client-side redirect using HTMX navigation to the specified URL.
///
/// [Official Documentation](https://htmx.org/headers/hx-location/)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.location("/dashboard")
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn location(url: String) -> #(String, String) {
  #("HX-Location", url)
}

/// Returns HX-Location header with advanced options.
///
/// This allows you to specify additional options for the client-side redirect,
/// such as target element, swap strategy, event source, and additional values.
///
/// [Official Documentation](https://htmx.org/headers/hx-location/)
///
/// ## Example
/// ```gleam
/// let config =
///   hx_header.location("/dashboard")
///   |> hx_header.with_target("#main")
///   |> hx_header.with_swap("innerHTML")
///
/// let #(name, value) = hx_header.location_with(config)
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn location_with(config config: LocationConfig) -> #(String, String) {
  #("HX-Location", build_location_json(config) |> json.to_string)
}

// ==== TRIGGER HEADERS ====

/// Returns HX-Trigger header to trigger client-side events.
///
/// This triggers events on the client-side immediately after receiving the response.
/// Events can be simple (just a name) or detailed (with a JSON payload).
///
/// [Official Documentation](https://htmx.org/headers/hx-trigger/)
///
/// ## Examples
///
/// Simple event:
/// ```gleam
/// let #(name, value) = hx_header.trigger([
///   hx_header.SimpleTrigger("reload")
/// ])
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
///
/// Event with details:
/// ```gleam
/// let details = json.object([
///   #("message", json.string("Success!")),
///   #("level", json.string("info"))
/// ])
///
/// let #(name, value) = hx_header.hx_trigger([
///   hx_header.DetailedTrigger("showNotification", details)
/// ])
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
///
/// Multiple events:
/// ```gleam
/// let #(name, value) = hx_header.trigger([
///   hx_header.SimpleTrigger("reload"),
///   hx_header.SimpleTrigger("clearForm")
/// ])
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn trigger(events: List(TriggerEvent)) -> #(String, String) {
  #("HX-Trigger", build_trigger_value(events))
}

/// Returns HX-Trigger-After-Swap header to trigger events after the swap phase.
///
/// This triggers events after the swap has occurred but before the settle phase.
///
/// [Official Documentation](https://htmx.org/headers/hx-trigger/)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.trigger_after_swap([
///   hx_header.SimpleTrigger("highlightNew")
/// ])
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn trigger_after_swap(events: List(TriggerEvent)) -> #(String, String) {
  #("HX-Trigger-After-Swap", build_trigger_value(events))
}

/// Returns HX-Trigger-After-Settle header to trigger events after the settle phase.
///
/// This triggers events after the settle phase has completed.
///
/// [Official Documentation](https://htmx.org/headers/hx-trigger/)
///
/// ## Example
/// ```gleam
/// let #(name, value) = hx_header.trigger_after_settle([
///   hx_header.SimpleTrigger("scrollToTop")
/// ])
/// wisp.ok()
/// |> wisp.set_header(name, value)
/// ```
pub fn trigger_after_settle(events: List(TriggerEvent)) -> #(String, String) {
  #("HX-Trigger-After-Settle", build_trigger_value(events))
}

// ==== HELPER FUNCTIONS ====

fn build_trigger_value(events: List(TriggerEvent)) -> String {
  case events {
    [] -> ""
    [SimpleTrigger(name)] -> name
    _ ->
      case all_simple(events) {
        True -> {
          events
          |> list.map(fn(event) {
            let assert SimpleTrigger(name) = event
            name
          })
          |> string.join(", ")
        }
        False -> build_trigger_json(events) |> json.to_string
      }
  }
}

fn all_simple(events: List(TriggerEvent)) -> Bool {
  list.all(events, fn(event) {
    case event {
      SimpleTrigger(_) -> True
      DetailedTrigger(_, _) -> False
    }
  })
}

fn build_trigger_json(events: List(TriggerEvent)) -> json.Json {
  events
  |> list.map(fn(event) {
    case event {
      SimpleTrigger(name) -> #(name, json.null())
      DetailedTrigger(name, details) -> #(name, details)
    }
  })
  |> json.object
}

fn build_location_json(config: LocationConfig) -> json.Json {
  let base = [#("path", json.string(config.path))]

  let with_source = case config.source {
    Some(source) -> list.append(base, [#("source", json.string(source))])
    None -> base
  }

  let with_event = case config.event {
    Some(event) -> list.append(with_source, [#("event", json.string(event))])
    None -> with_source
  }

  let with_target = case config.target {
    Some(target) -> list.append(with_event, [#("target", json.string(target))])
    None -> with_event
  }

  let with_swap = case config.swap {
    Some(swap) -> list.append(with_target, [#("swap", json.string(swap))])
    None -> with_target
  }

  let with_values = case config.values {
    Some(values) -> list.append(with_swap, [#("values", values)])
    None -> with_swap
  }

  json.object(with_values)
}

// ==== BUILDER PATTERN FOR LOCATIONCONFIG ====

/// Creates a new LocationConfig with the specified path.
///
/// Use the builder functions to add additional options.
///
/// ## Example
/// ```gleam
/// let config =
///   hx_header.location_config("/dashboard")
///   |> hx_header.target("#main")
///   |> hx_header.swap("innerHTML")
/// ```
pub fn location_config(path: String) -> LocationConfig {
  LocationConfig(
    path: path,
    source: None,
    event: None,
    target: None,
    swap: None,
    values: None,
  )
}

/// Sets the target element for the location redirect.
///
/// ## Example
/// ```gleam
/// hx_header.location_config("/page")
/// |> hx_header.target("#content")
/// ```
pub fn target(config: LocationConfig, target: String) -> LocationConfig {
  LocationConfig(..config, target: Some(target))
}

/// Sets the swap strategy for the location redirect.
///
/// ## Example
/// ```gleam
/// hx_header.location_config("/page")
/// |> hx_header.swap("outerHTML")
/// ```
pub fn swap(config: LocationConfig, swap: String) -> LocationConfig {
  LocationConfig(..config, swap: Some(swap))
}

/// Sets the event that triggered the navigation.
///
/// ## Example
/// ```gleam
/// hx_header.location_config("/page")
/// |> hx_header.event("click")
/// ```
pub fn event(config: LocationConfig, event: String) -> LocationConfig {
  LocationConfig(..config, event: Some(event))
}

/// Sets the source element for the location redirect.
///
/// ## Example
/// ```gleam
/// hx_header.location_config("/page")
/// |> hx_header.source("#button-1")
/// ```
pub fn source(config: LocationConfig, source: String) -> LocationConfig {
  LocationConfig(..config, source: Some(source))
}

/// Sets additional values to include with the location redirect.
///
/// ## Example
/// ```gleam
/// let values = json.object([
///   #("userId", json.int(123))
/// ])
///
/// hx_header.location_config("/page")
/// |> hx_header.values(values)
/// ```
pub fn values(config: LocationConfig, values: json.Json) -> LocationConfig {
  LocationConfig(..config, values: Some(values))
}
