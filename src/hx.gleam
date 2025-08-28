import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute.{attribute}

pub type Timing {
  Seconds(Int)
  Milliseconds(Int)
}

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

pub type SyncOption {
  Default(css_selector: String)
  Drop(css_selector: String)
  Abort(css_selector: String)
  Replace(css_selector: String)
  SyncQueue(css_selector: String, queue: Queue)
}

pub type Scroll {
  Top
  Bottom
}

pub type SwapOption {
  Transition(Bool)
  Swap(Timing)
  Settle(Timing)
  IgnoreTitle(Bool)
  Scroll(Scroll)
  Show(Scroll)
  FocusScroll(Bool)
}

pub type ExtendedCssSelector {
  CssSelector(css_selector: String)
  Document
  Window
  Closest(css_selector: String)
  Find(css_selector: String)
  Next(css_selector: Option(String))
  Previous(css_selector: Option(String))
  This
}

pub type Queue {
  First
  Last
  All
}

/// # Event
/// Used by the `trigger` function. 
///
/// A trigger can also have additional modifiers that change its behavior, represented as a `List(EventModifier)`.
pub type Event {
  Event(event: String, modifiers: List(EventModifier))
}

pub type EventModifier {
  Once
  Changed
  Delay(Timing)
  Throttle(Timing)
  From(extended_css_selector: ExtendedCssSelector)
  Target(css_selector: String)
  Consume
  QueueEvent(Option(Queue))
}

fn sync_option_to_string(sync_option: SyncOption) {
  case sync_option {
    Drop(selector) -> selector <> ":drop"
    Abort(selector) -> selector <> ":abort"
    Replace(selector) -> selector <> ":replace"
    SyncQueue(selector, First) -> selector <> ":queue first"
    SyncQueue(selector, All) -> selector <> ":queue all"
    SyncQueue(selector, Last) -> selector <> ":queue last"
    Default(selector) -> selector
  }
}

fn swap_to_string(swap: Swap) {
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

fn swap_option_to_string(swap_option: SwapOption) {
  case swap_option {
    Transition(True) -> "transition:true"
    Transition(False) -> "transition:false"
    Swap(timing_declaration) ->
      "swap:" <> timing_declaration_to_string(timing_declaration)
    Settle(timing_declaration) ->
      "settle:" <> timing_declaration_to_string(timing_declaration)
    IgnoreTitle(True) -> "ignoreTitle:true"
    IgnoreTitle(False) -> "ignoreTitle:false"
    Scroll(Top) -> "scroll:top"
    Scroll(Bottom) -> "scroll:bottom"
    Show(Top) -> "show:top"
    Show(Bottom) -> "show:bottom"
    FocusScroll(True) -> "focus-scroll:true"
    FocusScroll(False) -> "focus-scroll:false"
  }
}

fn extended_css_selector_to_string(
  extended_css_selector: ExtendedCssSelector,
) -> String {
  case extended_css_selector {
    CssSelector(css_selector) -> css_selector
    Document -> "document"
    Window -> "window"
    Closest(css_selector) -> "closest " <> css_selector
    Find(css_selector) -> "find " <> css_selector
    Next(css_selector) -> "next " <> option.unwrap(css_selector, "")
    Previous(css_selector) -> "previous " <> option.unwrap(css_selector, "")
    This -> "this"
  }
}

fn queue_to_string(queue: Option(Queue)) -> String {
  case queue {
    Some(First) -> "first"
    Some(Last) -> "last"
    Some(All) -> "all"
    None -> "none"
  }
}

@internal
pub fn timing_declaration_to_string(timing: Timing) {
  case timing {
    Seconds(n) -> int.to_string(n) <> "s"
    Milliseconds(n) -> int.to_string(n) <> "ms"
  }
}

fn event_to_string(event: Event) {
  event.event
  <> list.map(event.modifiers, fn(e) { " " <> event_modifier_to_string(e) })
  |> string.join("")
}

fn event_modifier_to_string(event_modifier event_modifier: EventModifier) {
  case event_modifier {
    Once -> "once"
    Changed -> "changed"
    Delay(timing) -> "delay:" <> timing_declaration_to_string(timing)
    Throttle(timing) -> "throttle:" <> timing_declaration_to_string(timing)
    From(extended_css_selector) ->
      "from:" <> extended_css_selector_to_string(extended_css_selector)
    Target(css_selector) -> "target:" <> css_selector
    Consume -> "consume"
    QueueEvent(queue) -> "queue:" <> queue_to_string(queue)
  }
}

/// # hx-get
/// Issues a GET request to the given URL when the element is triggered.
/// By default, AJAX requests are triggered by the “natural” event of an element:
///
/// * input, textarea & select are triggered on the change event
/// * form is triggered on the submit event
/// * everything else is triggered by the click event
///
/// If you want different behavior you can use the hx-trigger attribute, provided by lustre_hx.trigger, to specify which event will cause the request.
pub fn get(url url: String) {
  attribute("hx-get", url)
}

/// # hx-post
/// Issues a POST request to the given URL when the element is triggered. By default, AJAX requests are triggered by the “natural” event of an element:
///
/// * input, textarea & select are triggered on the change event
/// * form is triggered on the submit event
/// * everything else is triggered by the click event
///
/// If you want different behavior you can use the hx-trigger attribute, provided by lustre_hx.trigger, to specify which event will cause the request.
pub fn post(url url: String) {
  attribute("hx-post", url)
}

/// # hx-put
/// Issues a PUT request to the given URL when the element is triggered. By default, AJAX requests are triggered by the “natural” event of an element:
///
/// * input, textarea & select are triggered on the change event
/// * form is triggered on the submit event
/// * everything else is triggered by the click event
///
/// If you want different behavior you can use the hx-trigger attribute, provided by lustre_hx.trigger, to specify which event will cause the request.
pub fn put(url url: String) {
  attribute("hx-put", url)
}

/// # hx-patch
/// Issues a PATCH request to the given URL when the element is triggered. By default, AJAX requests are triggered by the “natural” event of an element:
///
/// * input, textarea & select are triggered on the change event
/// * form is triggered on the submit event
/// * everything else is triggered by the click event
///
/// If you want different behavior you can use the hx-trigger attribute, provided by lustre_hx.trigger, to specify which event will cause the request.
pub fn patch(url url: String) {
  attribute("hx-patch", url)
}

/// # hx-delete
/// Issues a DELETE request to the given URL when the element is triggered. By default, AJAX requests are triggered by the “natural” event of an element:
///
/// * input, textarea & select are triggered on the change event
/// * form is triggered on the submit event
/// * everything else is triggered by the click event
///
/// If you want different behavior you can use the hx-trigger attribute, provided by lustre_hx.trigger, to specify which event will cause the request.
pub fn delete(url url: String) {
  attribute("hx-delete", url)
}

//
/// # hx-trigger
/// By default, AJAX requests are triggered by the “natural” event of an element:
///
/// * input, textarea & select are triggered on the change event
/// * form is triggered on the submit event
/// * everything else is triggered by the click event
///
/// If you want different behavior you can use the hx-trigger attribute to specify which event will cause the request.
pub fn trigger(events: List(Event)) {
  let events =
    events
    |> list.map(event_to_string)
    |> string.join(", ")
  attribute("hx-trigger", events)
}

/// # Polling trigger
/// Creates an attribute that triggers a request on a polling basis.
/// 
/// * `timing` specifies how frequently the polling should occur (Seconds or Milliseconds)
/// * `filters` optional conditions that can filter when the polling is active
///
/// ## Examples
/// ```gleam
/// // Simple polling every 5 seconds
/// hx.trigger_polling(timing: hx.Seconds(5), filters: None)
///
/// // Polling with a condition - only poll when element is visible
/// hx.trigger_polling(timing: hx.Seconds(10), filters: Some("intersect"))
///
/// // Polling with a custom condition
/// hx.trigger_polling(timing: hx.Milliseconds(500), filters: Some("this.value.length > 3"))
/// ```
pub fn trigger_polling(timing timing: Timing, filters filters: Option(String)) {
  case filters {
    Some(filters) ->
      attribute(
        "hx-trigger",
        "every "
          <> timing_declaration_to_string(timing)
          <> " ["
          <> filters
          <> "]",
      )
    None ->
      attribute("hx-trigger", "every " <> timing_declaration_to_string(timing))
  }
}

/// # Load with polling trigger
/// Creates an attribute that triggers a request on page load and then continues on a polling basis.
/// 
/// * `timing` specifies how frequently the polling should occur (Seconds or Milliseconds)
/// * `filters` conditions that can filter when the polling is active (required)
///
/// ## Example
/// ```gleam
/// // Poll every 5 seconds while the element is visible
/// hx.trigger_load_polling(timing: hx.Seconds(5), filters: "when_visible")
/// 
/// // Poll every 2 seconds while a condition is met
/// hx.trigger_load_polling(timing: hx.Seconds(2), filters: "this.getAttribute('data-ready') === 'true'")
/// ```
pub fn trigger_load_polling(timing timing: Timing, filters filters: String) {
  attribute(
    "hx-trigger",
    "load every "
      <> timing_declaration_to_string(timing)
      <> " ["
      <> filters
      <> "]",
  )
}

/// # hx-indicator
/// Shows elements during the AJAX request.
/// 
/// The `hx-indicator` attribute allows you to specify which element will have the `htmx-request` class
/// during a request. This can be used to show spinners or loading indicators while the request is in progress.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, span, text}
/// import hx
///
/// // Show a loading indicator during request
/// div([hx.get("/data"), hx.indicator(".loading-indicator")], [
///   span([class("loading-indicator")], [text("Loading...")]),
///   button([], [text("Load Data")])
/// ])
/// ```
pub fn indicator(css_selector_or_closest css_selector_or_closest: String) {
  attribute("hx-indicator", css_selector_or_closest)
}

/// # hx-target
/// Specifies the target element to swap content into.
/// 
/// By default, htmx swaps content into the element that triggered the request.
/// The `hx-target` attribute allows you to target a different element for content swapping.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Target a specific element with ID
///   button([hx.get("/data"), hx.target(hx.CssSelector("#result"))], [
///     text("Load Data")
///   ]),
///   
///   // Using 'this' to target the element itself
///   button([hx.get("/status"), hx.target(hx.This)], [
///     text("Check Status")
///   ]),
///   
///   // Using 'closest' to target a parent element
///   div([class("card")], [
///     button([hx.get("/content"), hx.target(hx.Closest(".card"))], [
///       text("Refresh Card")
///     ])
///   ]),
///   
///   div([id("result")], [])
/// ])
/// ```
pub fn target(extended_css_selector extended_css_selector: ExtendedCssSelector) {
  attribute("hx-target", extended_css_selector_to_string(extended_css_selector))
}

/// # hx-swap
/// Controls how content is swapped into the DOM.
/// 
/// The `hx-swap` attribute allows you to specify how the response will be swapped relative to the target.
/// You can control the swap method (innerHTML, outerHTML, etc.) and additional options through modifiers.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Basic swap using innerHTML (default)
///   button([hx.get("/content"), hx.swap(hx.InnerHTML, None)], [
///     text("Load Content")
///   ]),
///   
///   // Using outerHTML with transition
///   button([hx.get("/replace"), hx.swap(hx.OuterHTML, Some(hx.Transition(True)))], [
///     text("Replace Completely")
///   ]),
///   
///   // Add content after the target with a timing modifier
///   button([hx.get("/append"), hx.swap(hx.After, Some(hx.Swap(hx.Milliseconds(500))))], [
///     text("Append Slowly")
///   ]),
///   
///   // Add content and scroll to top
///   button([hx.get("/more"), hx.swap(hx.Beforeend, Some(hx.Scroll(hx.Top)))], [
///     text("Load More and Scroll")
///   ])
/// ])
/// ```
pub fn swap(swap swap: Swap, with_option option: Option(SwapOption)) {
  case option {
    Some(option) -> {
      swap
      |> swap_to_string
      |> string.append(" " <> swap_option_to_string(option))
      |> attribute("hx-swap", _)
    }
    None ->
      swap
      |> swap_to_string
      |> attribute("hx-swap", _)
  }
}

/// # hx-swap-oob
/// Allows you to specify that some content in a response should be swapped "out of band" (somewhere other than the target).
/// 
/// This is useful for updating multiple parts of the page with a single request. Combines with the `hx-select-oob` attribute.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Basic out-of-band swap
///   button([
///     hx.get("/update-multiple"),
///     hx.swap_oob(swap: hx.InnerHTML, with_css_selector: None, with_modifier: None)
///   ], [
///     text("Update Multiple Elements")
///   ]),
///   
///   // With CSS selector targeting
///   button([
///     hx.get("/update-status"),
///     hx.swap_oob(swap: hx.InnerHTML, with_css_selector: Some("#status"), with_modifier: None)
///   ], [
///     text("Update Status")
///   ]),
///   
///   // With both CSS selector and modifier
///   button([
///     hx.get("/update-content"),
///     hx.swap_oob(
///       swap: hx.Beforeend, 
///       with_css_selector: Some("#log"), 
///       with_modifier: Some(hx.Scroll(hx.Bottom))
///     )
///   ], [
///     text("Add To Log")
///   ]),
///   
///   div([id("status")], [text("Status: Ready")]),
///   div([id("log")], [])
/// ])
/// ```
pub fn swap_oob(
  swap swap: Swap,
  with_css_selector css_selector: Option(String),
  with_modifier modifier: Option(SwapOption),
) {
  case css_selector, modifier {
    Some(css_selector), Some(option) -> {
      swap
      |> swap_to_string
      |> string.append("," <> css_selector)
      |> string.append(" " <> swap_option_to_string(option))
      |> attribute("hx-swap-oob", _)
    }
    None, Some(option) -> {
      swap
      |> swap_to_string
      |> string.append(" " <> swap_option_to_string(option))
      |> attribute("hx-swap-oob", _)
    }
    Some(css_selector), None ->
      swap
      |> swap_to_string
      |> string.append("," <> css_selector)
      |> attribute("hx-swap-oob", _)
    None, None ->
      swap
      |> swap_to_string
      |> attribute("hx-swap-oob", _)
  }
}

/// # hx-sync
/// Synchronizes AJAX requests with other elements.
/// 
/// The `hx-sync` attribute allows you to coordinate AJAX requests so that they do not all fire at once
/// or in a way that might confuse the user or overwhelm the server. You can specify different sync options
/// to control request behavior.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Default sync option with a form
///   button([
///     hx.get("/data"), 
///     hx.sync([hx.Default("#myForm")])
///   ], [
///     text("Synchronized with form")
///   ]),
///   
///   // Drop previous requests
///   button([
///     hx.get("/api/search"), 
///     hx.sync([hx.Drop("#searchForm")])
///   ], [
///     text("New search cancels previous")
///   ]),
///   
///   // Queue requests
///   button([
///     hx.post("/api/queue"), 
///     hx.sync([hx.SyncQueue("#queueTarget", hx.First)])
///   ], [
///     text("Queue (first)")
///   ]),
///   
///   // Multiple sync options
///   button([
///     hx.post("/api/complex"), 
///     hx.sync([hx.Drop("#form1"), hx.SyncQueue("#form2", hx.Last)])
///   ], [
///     text("Complex sync")
///   ])
/// ])
/// ```
pub fn sync(syncronize_on: List(SyncOption)) {
  attribute(
    "hx-sync",
    list.map(syncronize_on, sync_option_to_string) |> string.join(" "),
  )
}

/// # hx-select
/// Selects a subset of the server response to process.
/// 
/// The `hx-select` attribute allows you to select a specific part of the server response for swapping,
/// using CSS selectors. This is useful when you want to extract only a portion of a larger HTML response.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Select only the div with id "content" from the response
///   button([
///     hx.get("/page"), 
///     hx.select("#content")
///   ], [
///     text("Load Content Only")
///   ]),
///   
///   // Select elements matching a class
///   button([
///     hx.get("/items"), 
///     hx.select(".item")
///   ], [
///     text("Load Items")
///   ])
/// ])
/// ```
pub fn select(css_selector: String) {
  attribute("hx-select", css_selector)
}

/// # Out-of-band selection
/// Selects content from a response to be swapped in to the current page.
/// 
/// The `select_oob` function allows you to process multiple pieces of content from a response,
/// selecting them with different CSS selectors and applying different swap strategies.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Basic select with no swap strategies
///   button([
///     hx.get("/update"),
///     hx.select_oob(".status", [])
///   ], [
///     text("Update Status")
///   ]),
///   
///   // With a single swap strategy
///   button([
///     hx.get("/update-card"),
///     hx.select_oob(".card-content", [hx.InnerHTML])
///   ], [
///     text("Update Card Content")
///   ]),
///   
///   // With multiple swap strategies
///   button([
///     hx.get("/update-multiple"),
///     hx.select_oob(".data", [hx.OuterHTML, hx.After, hx.Delete])
///   ], [
///     text("Complex Update")
///   ])
/// ])
/// ```
pub fn select_oob(css_selector: String, swap_strategies: List(Swap)) {
  let swap_strategies =
    swap_strategies
    |> list.map(swap_to_string)
    |> string.join(",")
  case swap_strategies {
    "" -> attribute("hx-select", css_selector)
    _ -> attribute("hx-select", css_selector <> ":" <> swap_strategies)
  }
}

/// # hx-push-url
/// Pushes a URL into the browser's location bar.
/// 
/// The `hx-push-url` attribute allows you to update the browser's URL without causing a full page reload. 
/// This is useful for maintaining proper history navigation and bookmarkable URLs with AJAX.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Push URL to browser history
///   button([
///     hx.get("/products/123"), 
///     hx.push_url(True)
///   ], [
///     text("View Product")
///   ]),
///   
///   // Don't push URL (useful for background updates)
///   button([
///     hx.get("/refresh-status"), 
///     hx.push_url(False)
///   ], [
///     text("Refresh Status")
///   ])
/// ])
/// ```
pub fn push_url(bool: Bool) {
  case bool {
    True -> attribute("hx-push-url", "true")
    False -> attribute("hx-push-url", "false")
  }
}

/// # hx-confirm
/// Shows a confirmation dialog before making a request.
/// 
/// The `hx-confirm` attribute is useful for dangerous or destructive operations that you
/// want the user to confirm before proceeding.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Simple confirmation message
///   button([
///     hx.delete("/user/123"), 
///     hx.confirm("Are you sure you want to delete this user?")
///   ], [
///     text("Delete User")
///   ])
/// ])
/// ```
pub fn confirm(confirm_text: String) {
  attribute("hx-confirm", confirm_text)
}

/// # hx-boost
/// Makes regular links and forms use AJAX for navigation.
/// 
/// The `hx-boost` attribute progressively enhances links and forms to use AJAX instead of full page 
/// reloads, while falling back to standard navigation if JavaScript is disabled.
///
/// ## Example
/// ```gleam
/// import lustre/element.{a, button, div, form, text}
/// import hx
///
/// // Apply boost to an entire section - all links/forms inside will use AJAX
/// div([hx.boost(True)], [
///   a([href("/products")], [text("Products")]),
///   a([href("/about")], [text("About")]),
///   form([action("/search"), method("get")], [
///     // Form elements...
///     button([], [text("Search")])
///   ])
/// ])
/// ```
pub fn boost(set: Bool) {
  case set {
    True -> attribute("hx-boost", "true")
    False -> attribute("hx-boost", "false")
  }
}

/// # Hyperscript integration (_)
/// Adds hyperscript to an element using the "_" attribute.
/// 
/// Hyperscript is a companion language for HTMX that allows you to add client-side interactivity
/// with a concise, readable syntax.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Toggle a class on click
///   button([
///     hx.hyper_script("on click toggle .active on me")
///   ], [
///     text("Toggle Active")
///   ]),
///   
///   // Hide an element after a delay
///   div([
///     hx.hyper_script("on load wait 3s then add .hidden")
///   ], [
///     text("I will disappear in 3 seconds")
///   ])
/// ])
/// ```
pub fn hyper_script(script: String) {
  attribute("_", script)
}

/// # hx-vals
/// Sets values to be included in requests.
/// 
/// The `hx-vals` attribute allows you to add additional values to an AJAX request.
/// This is useful for including data that isn't part of a form.
///
/// ## Example
/// ```gleam
/// import gleam/json
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Add static JSON values to the request
///   button([
///     hx.get("/api/fetch"), 
///     hx.vals(
///       json.object([
///         #("user_id", json.string("123")), 
///         #("version", json.number(2.0))
///       ]),
///       False
///     )
///   ], [
///     text("Fetch Data")
///   ]),
///   
///   // Use JavaScript to compute values at runtime
///   button([
///     hx.post("/api/save"), 
///     hx.vals(
///       json.object([
///         #("timestamp", json.string("now"))
///       ]),
///       True
///     )
///   ], [
///     text("Save with Timestamp")
///   ])
/// ])
/// ```
pub fn vals(json: json.Json, compute_value: Bool) {
  case compute_value {
    True -> attribute("hx-vals", "js:" <> json.to_string(json))
    False -> attribute("hx-vals", json.to_string(json))
  }
}

/// # hx-disable
/// Disables HTMX processing for a given element.
/// 
/// The `hx-disable` attribute is useful when you want to temporarily or conditionally
/// disable HTMX processing on an element.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // This button will not process HTMX attributes
///   button([
///     hx.get("/api/data"),  // This will be ignored 
///     hx.disable()
///   ], [
///     text("HTMX Disabled")
///   ])
/// ])
/// ```
pub fn disable() {
  attribute("hx-disable", "")
}

/// # hx-disable-elt
/// Disables elements during requests.
/// 
/// The `hx-disable-elt` attribute allows you to specify elements that should be disabled
/// during the course of an AJAX request. Useful for preventing duplicate form submissions.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, form, input, text}
/// import hx
///
/// div([], [
///   form([
///     hx.post("/api/submit"),
///     // Disable the submit button during the request
///     hx.disable_elt([hx.CssSelector("button[type='submit']")])
///   ], [
///     input([type_("text"), name("name")], []),
///     button([type_("submit")], [text("Submit")])
///   ]),
///   
///   // Disable multiple elements
///   form([
///     hx.post("/api/complex-submit"),
///     hx.disable_elt([
///       hx.CssSelector("input"), 
///       hx.CssSelector("button"), 
///       hx.This
///     ])
///   ], [
///     // Form elements...
///   ])
/// ])
/// ```
pub fn disable_elt(extended_css_selectors: List(ExtendedCssSelector)) {
  let selectors =
    extended_css_selectors
    |> list.map(extended_css_selector_to_string)
    |> string.join(",")
  attribute("hx-disable-elt", selectors)
}

/// # hx-disinherit
/// Controls which attributes are inherited from ancestor elements.
/// 
/// The `hx-disinherit` attribute allows you to prevent specific HTMX attributes from being
/// inherited by an element from its ancestors.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([
///   // Parent has a trigger which will be inherited by children
///   hx.trigger([hx.Event(event: "click", modifiers: [])])
/// ], [
///   // This button will inherit the click trigger
///   button([hx.get("/data1")], [text("Inherited Trigger")]),
///   
///   // This button will NOT inherit the click trigger
///   button([
///     hx.get("/data2"),
///     hx.disinherit(["hx-trigger"])
///   ], [
///     text("No Trigger Inheritance")
///   ])
/// ])
/// ```
pub fn disinherit(attributes: List(String)) {
  let attributes = attributes |> string.join(" ")
  attribute("hx-disinherit", attributes)
}

/// # hx-disinherit (all attributes)
/// Prevents inheritance of all HTMX attributes from ancestor elements.
/// 
/// The `disinherit_all` function is a shorthand for preventing the inheritance of
/// all HTMX attributes, which can help isolate parts of your UI from unwanted inheritance.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([
///   // Parent has multiple HTMX attributes
///   hx.get("/parent-data"),
///   hx.trigger([hx.Event(event: "click", modifiers: [])]),
///   hx.swap(hx.InnerHTML, None)
/// ], [
///   // This button will inherit all HTMX attributes from parent
///   button([], [text("Inherited Everything")]),
///   
///   // This button won't inherit any HTMX attributes
///   button([
///     hx.post("/isolated"),
///     hx.disinherit_all()
///   ], [
///     text("No Inheritance")
///   ])
/// ])
/// ```
pub fn disinherit_all() {
  attribute("hx-disinherit", "*")
}

/// # hx-encoding
/// Sets the encoding type for the request.
/// 
/// The `hx-encoding` attribute allows you to specify the encoding for HTMX requests,
/// particularly useful for form submissions that include file uploads.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, form, input, text}
/// import hx
///
/// div([], [
///   // Form with file uploads
///   form([
///     hx.post("/upload"),
///     hx.encoding("multipart/form-data")
///   ], [
///     input([type_("file"), name("file")], []),
///     button([type_("submit")], [text("Upload File")])
///   ])
/// ])
/// ```
pub fn encoding(encoding: String) {
  attribute("hx-encoding", encoding)
}

/// # hx-ext
/// Includes one or more HTMX extensions for an element.
/// 
/// HTMX extensions allow you to extend the functionality of HTMX with additional
/// features and behaviors.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Using the client-side templates extension
///   button([
///     hx.get("/api/data"),
///     hx.ext(["client-side-templates"])
///   ], [
///     text("Load With Template")
///   ]),
///   
///   // Using multiple extensions
///   button([
///     hx.post("/api/data"),
///     hx.ext(["json-enc", "ajax-header"])
///   ], [
///     text("With Multiple Extensions")
///   ])
/// ])
/// ```
pub fn ext(ext: List(String)) {
  let ext = ext |> string.join(",")
  attribute("hx-ext", ext)
}

/// # hx-headers
/// Adds custom headers to AJAX requests.
/// 
/// The `hx-headers` attribute allows you to specify additional HTTP headers to be
/// included in an AJAX request.
///
/// ## Example
/// ```gleam
/// import gleam/json
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Static headers
///   button([
///     hx.get("/api/data"), 
///     hx.headers(
///       json.object([
///         #("X-Requested-With", json.string("XMLHttpRequest")),
///         #("Authorization", json.string("Bearer token123"))
///       ]),
///       False
///     )
///   ], [
///     text("With Custom Headers")
///   ]),
///   
///   // Dynamic headers using JavaScript
///   button([
///     hx.post("/api/submit"), 
///     hx.headers(
///       json.object([
///         #("X-Session-Token", json.string("localStorage.getItem('token')"))
///       ]),
///       True
///     )
///   ], [
///     text("With Dynamic Headers")
///   ])
/// ])
/// ```
pub fn headers(headers: json.Json, compute_value: Bool) {
  case compute_value {
    True -> attribute("hx-headers", "js:" <> json.to_string(headers))
    False -> attribute("hx-headers", json.to_string(headers))
  }
}

/// # hx-history
/// Controls if the element should be included in the browser history.
/// 
/// The `hx-history` attribute allows you to control whether requests for a given element
/// should be recorded in the browser's history.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // This will be added to browser history (default behavior with push_url)
///   button([
///     hx.get("/page1"),
///     hx.push_url(True),
///     hx.history(True)
///   ], [
///     text("Navigate with History")
///   ]),
///   
///   // This will not be added to browser history even though push_url is True
///   button([
///     hx.get("/temp-view"),
///     hx.push_url(True),
///     hx.history(False)
///   ], [
///     text("Temporary View")
///   ])
/// ])
/// ```
pub fn history(should_be_saved: Bool) {
  case should_be_saved {
    True -> attribute("hx-history", "true")
    False -> attribute("hx-history", "false")
  }
}

/// # hx-history-elt
/// Marks the element that should be included in the browser history.
/// 
/// The `hx-history-elt` attribute specifies that this element's innerHTML should be
/// saved and restored when the user navigates through browser history.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // The main content area that should be saved in browser history
///   div([hx.history_elt()], [
///     text("This content will be saved in browser history")
///   ]),
///   
///   // Navigation buttons
///   button([hx.get("/page1"), hx.push_url(True)], [text("Page 1")]),
///   button([hx.get("/page2"), hx.push_url(True)], [text("Page 2")])
/// ])
/// ```
pub fn history_elt() {
  attribute("hx-history-elt", "")
}

/// # hx-include
/// Includes additional elements in the AJAX request.
/// 
/// The `hx-include` attribute allows you to include values from other elements
/// in the current request. This is useful for gathering data from multiple parts of a form.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, form, input, text}
/// import hx
///
/// div([], [
///   form([id("search-form")], [
///     input([type_("text"), name("query")], []),
///     // Filter options outside the form
///     div([id("filters")], [
///       input([type_("checkbox"), name("filter1"), value("yes")], []),
///       text("Include results from archive")
///     ])
///   ]),
///   
///   // This button includes both the form and the filters
///   button([
///     hx.get("/search"),
///     hx.include(hx.CssSelector("#search-form, #filters"))
///   ], [
///     text("Search")
///   ])
/// ])
/// ```
pub fn include(extended_css_selector: ExtendedCssSelector) {
  attribute(
    "hx-include",
    extended_css_selector_to_string(extended_css_selector),
  )
}

/// # hx-inherit
/// Explicitly specifies which attributes to inherit from ancestors.
/// 
/// The `hx-inherit` attribute is the opposite of `hx-disinherit`. It allows you to specify
/// which HTMX attributes should be inherited from ancestor elements.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([
///   // Parent has multiple HTMX attributes
///   hx.get("/parent-data"),
///   hx.trigger([hx.Event(event: "click", modifiers: [])]),
///   hx.swap(hx.OuterHTML, None)
/// ], [
///   // This button will only inherit the hx-trigger attribute
///   button([
///     hx.post("/button-action"),
///     hx.inherit(["hx-trigger"])
///   ], [
///     text("Inherit Trigger Only")
///   ])
/// ])
/// ```
pub fn inherit(attributes: List(String)) {
  let attributes = attributes |> string.join(" ")
  attribute("hx-inherit", attributes)
}

/// # hx-inherit (all attributes)
/// Explicitly inherits all attributes from ancestors.
/// 
/// The `inherit_all` function ensures that all HTMX attributes are inherited,
/// which can be useful to override a previous `hx-disinherit` attribute.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([
///   // Block inheritance for all children
///   hx.get("/parent-data"),
///   hx.trigger([hx.Event(event: "click", modifiers: [])]),
///   hx.disinherit_all()
/// ], [
///   // This button won't inherit any HTMX attributes
///   button([hx.post("/action1")], [text("No Inheritance")]),
///   
///   // This button will force inheritance of all attributes
///   button([
///     hx.post("/action2"),
///     hx.inherit_all()
///   ], [
///     text("Force Inheritance")
///   ])
/// ])
/// ```
pub fn inherit_all() {
  attribute("hx-inherit", "*")
}

/// # hx-params
/// Controls which parameters are submitted with a request.
/// 
/// The `hx-params` attribute allows you to filter which parameters should be
/// submitted in an AJAX request, such as form fields.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, form, input, text}
/// import hx
///
/// div([], [
///   form([id("user-form")], [
///     input([type_("text"), name("username")], []),
///     input([type_("password"), name("password")], []),
///     input([type_("hidden"), name("csrf_token")], []),
///     
///     // Only send the username and csrf_token
///     button([
///       hx.post("/check-username"),
///       hx.params("username,csrf_token")
///     ], [
///       text("Check Username")
///     ]),
///     
///     // Send none of the form fields (only values from hx-vals would be sent)
///     button([
///       hx.post("/custom-action"),
///       hx.params("none")
///     ], [
///       text("Custom Action")
///     ]),
///     
///     // Send all except password
///     button([
///       hx.post("/save-profile"),
///       hx.params("not password")
///     ], [
///       text("Save Profile")
///     ])
///   ])
/// ])
/// ```
pub fn params(params: String) {
  attribute("hx-params", params)
}

/// # hx-preserve
/// Preserves an element's state between requests.
/// 
/// The `hx-preserve` attribute ensures that an element is not re-rendered when a
/// parent element is re-rendered by HTMX. This is useful for preserving
/// input values, scroll positions, etc.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, input, text, textarea}
/// import hx
///
/// div([id("form-container")], [
///   // This textarea will keep its content even when the parent is refreshed
///   textarea([hx.preserve()], []),
///   
///   // This will also keep its current input value
///   input([type_("text"), name("name"), hx.preserve()], []),
///   
///   // This button refreshes the parent container
///   button([
///     hx.get("/refresh-form"),
///     hx.target(hx.CssSelector("#form-container"))
///   ], [
///     text("Refresh Form")
///   ])
/// ])
/// ```
pub fn preserve() {
  attribute("hx-preserve", "")
}

/// # hx-prompt
/// Displays a prompt before submitting a request.
/// 
/// The `hx-prompt` attribute shows a prompt dialog that asks for user input before
/// making the AJAX request. The prompt value is included in the request.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Ask for a comment when deleting
///   button([
///     hx.delete("/items/123"),
///     hx.prompt("Please provide a reason for deletion:")
///   ], [
///     text("Delete Item")
///   ])
/// ])
/// ```
pub fn prompt(prompt_text: String) {
  attribute("hx-prompt", prompt_text)
}

/// # hx-replace-url (enable)
/// Replaces the current URL after the request completes.
/// 
/// The `replace_url` function enables URL replacement, which is useful for single-page
/// applications to update the browser's address bar without adding a history entry.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Replace the URL without adding to history
///   button([
///     hx.get("/view/123"),
///     hx.replace_url()
///   ], [
///     text("View Item")
///   ])
/// ])
/// ```
pub fn replace_url() {
  attribute("hx-replace", "true")
}

/// # hx-replace-url (disable)
/// Disables URL replacement for the request.
/// 
/// The `no_replace_url` function explicitly disables URL replacement,
/// which can be useful to override an inherited behavior.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([hx.replace_url()], [
///   // This button will replace the URL (inherited from parent)
///   button([hx.get("/view/1")], [text("View 1")]),
///   
///   // This button won't replace the URL
///   button([
///     hx.get("/view/2"),
///     hx.no_replace_url()
///   ], [
///     text("View 2")
///   ])
/// ])
/// ```
pub fn no_replace_url() {
  attribute("hx-replace", "false")
}

/// # hx-replace-url (with URL)
/// Replaces the current URL with a specified one.
/// 
/// The `replace_url_with` function allows you to specify a different URL to put in the browser's
/// address bar than the one that was requested.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Use a different URL in the address bar than the API endpoint
///   button([
///     hx.post("/api/items/add"),
///     hx.replace_url_with("/items")
///   ], [
///     text("Add Item")
///   ])
/// ])
/// ```
pub fn replace_url_with(url: String) {
  attribute("hx-replace", url)
}

/// # hx-request
/// Configures various aspects of the AJAX request.
/// 
/// The `hx-request` attribute allows you to configure various aspects of the AJAX request
/// using a simple JSON-like syntax.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, text}
/// import hx
///
/// div([], [
///   // Configure timeout and show progress
///   button([
///     hx.get("/api/long-process"),
///     hx.request("{timeout:10000, showProgress:true}")
///   ], [
///     text("Start Long Process")
///   ]),
///   
///   // Configure to not process responses
///   button([
///     hx.post("/api/fire-and-forget"),
///     hx.request("{noHeaders:true, ignoreTitle:true}")
///   ], [
///     text("Send Notification")
///   ])
/// ])
/// ```
pub fn request(request: String) {
  attribute("hx-request", request)
}

/// # hx-validate
/// Controls whether form validation should occur before a request.
/// 
/// The `hx-validate` attribute determines whether HTML5 validation should occur
/// on form inputs before a request is sent.
///
/// ## Example
/// ```gleam
/// import lustre/element.{button, div, form, input, text}
/// import hx
///
/// div([], [
///   form([], [
///     input([type_("email"), required(True), name("email")], []),
///     
///     // This will validate the email field
///     button([
///       hx.post("/api/subscribe"),
///       hx.validate(True)
///     ], [
///       text("Subscribe (with validation)")
///     ]),
///     
///     // This will skip validation
///     button([
///       hx.post("/api/quick-subscribe"),
///       hx.validate(False)
///     ], [
///       text("Quick Subscribe")
///     ])
///   ])
/// ])
/// ```
pub fn validate(bool: Bool) {
  case bool {
    True -> attribute("hx-validate", "true")
    False -> attribute("hx-validate", "false")
  }
}

// ==== HTMX EVENTS ====

/// # Common HTMX Events
/// 
/// Pre-defined common HTMX events that can be used with the trigger function.
/// These provide type-safe access to standard DOM and HTMX events.

/// Creates a load event that fires when the element loads
pub fn load_event() -> Event {
  Event(event: "load", modifiers: [])
}

/// Creates a DOMContentLoaded event 
pub fn dom_content_loaded_event() -> Event {
  Event(event: "DOMContentLoaded", modifiers: [])
}

/// Creates a click event
pub fn click_event() -> Event {
  Event(event: "click", modifiers: [])
}

/// Creates a change event (useful for form inputs)
pub fn change_event() -> Event {
  Event(event: "change", modifiers: [])
}

/// Creates a submit event (useful for forms)
pub fn submit_event() -> Event {
  Event(event: "submit", modifiers: [])
}

/// Creates a keyup event
pub fn keyup_event() -> Event {
  Event(event: "keyup", modifiers: [])
}

/// Creates a keydown event  
pub fn keydown_event() -> Event {
  Event(event: "keydown", modifiers: [])
}

/// Creates a focus event
pub fn focus_event() -> Event {
  Event(event: "focus", modifiers: [])
}

/// Creates a blur event
pub fn blur_event() -> Event {
  Event(event: "blur", modifiers: [])
}

/// Creates a mouseover event
pub fn mouseover_event() -> Event {
  Event(event: "mouseover", modifiers: [])
}

/// Creates a mouseout event
pub fn mouseout_event() -> Event {
  Event(event: "mouseout", modifiers: [])
}

/// Creates an input event (fires on every character input)
pub fn input_event() -> Event {
  Event(event: "input", modifiers: [])
}

/// Creates a scroll event
pub fn scroll_event() -> Event {
  Event(event: "scroll", modifiers: [])
}

/// Creates a resize event
pub fn resize_event() -> Event {
  Event(event: "resize", modifiers: [])
}

// ==== HTMX-SPECIFIC EVENTS ====

/// Creates an htmx:beforeRequest event
/// Fires before an HTMX request is made
pub fn htmx_before_request_event() -> Event {
  Event(event: "htmx:beforeRequest", modifiers: [])
}

/// Creates an htmx:afterRequest event  
/// Fires after an HTMX request completes
pub fn htmx_after_request_event() -> Event {
  Event(event: "htmx:afterRequest", modifiers: [])
}

/// Creates an htmx:beforeSwap event
/// Fires before content is swapped into the DOM
pub fn htmx_before_swap_event() -> Event {
  Event(event: "htmx:beforeSwap", modifiers: [])
}

/// Creates an htmx:afterSwap event
/// Fires after content has been swapped into the DOM
pub fn htmx_after_swap_event() -> Event {
  Event(event: "htmx:afterSwap", modifiers: [])
}

/// Creates an htmx:beforeSettle event
/// Fires before the settling phase of HTMX
pub fn htmx_before_settle_event() -> Event {
  Event(event: "htmx:beforeSettle", modifiers: [])
}

/// Creates an htmx:afterSettle event
/// Fires after the settling phase of HTMX
pub fn htmx_after_settle_event() -> Event {
  Event(event: "htmx:afterSettle", modifiers: [])
}

/// Creates an htmx:load event
/// Fires when new content has been loaded into the DOM by HTMX
pub fn htmx_load_event() -> Event {
  Event(event: "htmx:load", modifiers: [])
}

/// Creates an htmx:configRequest event
/// Fires before a request is configured, allows modification
pub fn htmx_config_request_event() -> Event {
  Event(event: "htmx:configRequest", modifiers: [])
}

/// Creates an htmx:responseError event
/// Fires when an HTTP error response is received
pub fn htmx_response_error_event() -> Event {
  Event(event: "htmx:responseError", modifiers: [])
}

/// Creates an htmx:sendError event
/// Fires when a network error occurs
pub fn htmx_send_error_event() -> Event {
  Event(event: "htmx:sendError", modifiers: [])
}

/// Creates an htmx:timeout event
/// Fires when a request times out
pub fn htmx_timeout_event() -> Event {
  Event(event: "htmx:timeout", modifiers: [])
}

/// Creates an htmx:validation:validate event
/// Fires when validation is run on a form
pub fn htmx_validation_validate_event() -> Event {
  Event(event: "htmx:validation:validate", modifiers: [])
}

/// Creates an htmx:validation:failed event
/// Fires when validation fails on a form  
pub fn htmx_validation_failed_event() -> Event {
  Event(event: "htmx:validation:failed", modifiers: [])
}

/// Creates an htmx:validation:halted event
/// Fires when validation is halted
pub fn htmx_validation_halted_event() -> Event {
  Event(event: "htmx:validation:halted", modifiers: [])
}

/// Creates an htmx:xhr:abort event
/// Fires when a request is aborted
pub fn htmx_xhr_abort_event() -> Event {
  Event(event: "htmx:xhr:abort", modifiers: [])
}

/// Creates an htmx:xhr:loadend event
/// Fires when a request load ends
pub fn htmx_xhr_loadend_event() -> Event {
  Event(event: "htmx:xhr:loadend", modifiers: [])
}

/// Creates an htmx:xhr:loadstart event
/// Fires when a request load starts
pub fn htmx_xhr_loadstart_event() -> Event {
  Event(event: "htmx:xhr:loadstart", modifiers: [])
}

/// Creates an htmx:xhr:progress event  
/// Fires during request progress
pub fn htmx_xhr_progress_event() -> Event {
  Event(event: "htmx:xhr:progress", modifiers: [])
}

// ==== INTERSECT EVENTS ====

/// Creates an intersect event with options
/// Fires when element enters/exits the viewport
/// 
/// ## Examples
/// ```gleam
/// // Simple intersect event
/// hx.intersect_event(None)
/// 
/// // Intersect with root margin
/// hx.intersect_event(Some("10px"))
/// 
/// // Intersect with multiple options  
/// hx.intersect_event(Some("10px 20px"))
/// ```
pub fn intersect_event(options: Option(String)) -> Event {
  case options {
    Some(opts) -> Event(event: "intersect", modifiers: [From(CssSelector(opts))])
    None -> Event(event: "intersect", modifiers: [])
  }
}

/// Creates an intersect event that fires only once
pub fn intersect_once_event(options: Option(String)) -> Event {
  case options {
    Some(opts) -> Event(event: "intersect", modifiers: [From(CssSelector(opts)), Once])
    None -> Event(event: "intersect", modifiers: [Once])
  }
}

// ==== EVENT HELPER FUNCTIONS ====

/// Creates a custom event with the given name
pub fn custom_event(event_name: String) -> Event {
  Event(event: event_name, modifiers: [])
}

/// Adds a delay modifier to an existing event
pub fn with_delay(event: Event, timing: Timing) -> Event {
  Event(event: event.event, modifiers: [Delay(timing), ..event.modifiers])
}

/// Adds a throttle modifier to an existing event  
pub fn with_throttle(event: Event, timing: Timing) -> Event {
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
pub fn with_from(event: Event, extended_css_selector: ExtendedCssSelector) -> Event {
  Event(event: event.event, modifiers: [From(extended_css_selector), ..event.modifiers])
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
pub fn with_queue(event: Event, queue: Option(Queue)) -> Event {
  Event(event: event.event, modifiers: [QueueEvent(queue), ..event.modifiers])
}
