# HX API Reference

Complete API reference for the HX HTMX integration library for Gleam/Lustre.

## Table of Contents

- [HTTP Methods](#http-methods)
- [Event System](#event-system)
  - [Common DOM Events](#common-dom-events)
  - [HTMX Lifecycle Events](#htmx-lifecycle-events)
  - [Intersect Events](#intersect-events)
  - [Event Modifiers](#event-modifiers)
  - [Polling](#polling)
- [Content Targeting & Swapping](#content-targeting--swapping)
- [Request Control](#request-control)
- [User Experience](#user-experience)
- [Form Handling](#form-handling)
- [Advanced Features](#advanced-features)
- [Types](#types)

## HTTP Methods

### `get(url: String) -> Attribute(msg)`
Issues a GET request to the given URL when triggered.

```gleam
button([hx.get("/api/data")], [text("Load Data")])
```

### `post(url: String) -> Attribute(msg)`
Issues a POST request to the given URL when triggered.

```gleam
button([hx.post("/api/create")], [text("Create Item")])
```

### `put(url: String) -> Attribute(msg)`
Issues a PUT request to the given URL when triggered.

```gleam
button([hx.put("/api/update/123")], [text("Update Item")])
```

### `patch(url: String) -> Attribute(msg)`
Issues a PATCH request to the given URL when triggered.

```gleam
button([hx.patch("/api/partial-update/123")], [text("Patch Item")])
```

### `delete(url: String) -> Attribute(msg)`
Issues a DELETE request to the given URL when triggered.

```gleam
button([hx.delete("/api/delete/123")], [text("Delete Item")])
```

## Event System

### Common DOM Events

Pre-defined functions for standard DOM events that return `Event` type for use with `trigger()`.

#### `click_event() -> Event`
```gleam
hx.trigger([hx.click_event()])
```

#### `change_event() -> Event`
Useful for form inputs.
```gleam
select([hx.get("/api/filter"), hx.trigger([hx.change_event()])], [...])
```

#### `submit_event() -> Event`
For form submissions.
```gleam
form([hx.post("/api/submit"), hx.trigger([hx.submit_event()])], [...])
```

#### `input_event() -> Event`
Fires on every character input.
```gleam
input([hx.get("/api/search"), hx.trigger([hx.input_event()])], [])
```

#### `focus_event() -> Event`
```gleam
input([hx.get("/api/focus-data"), hx.trigger([hx.focus_event()])], [])
```

#### `blur_event() -> Event`
```gleam
input([hx.post("/api/save"), hx.trigger([hx.blur_event()])], [])
```

#### `keyup_event() -> Event`
```gleam
input([hx.get("/api/search"), hx.trigger([hx.keyup_event()])], [])
```

#### `keydown_event() -> Event`
```gleam
input([hx.post("/api/keypress"), hx.trigger([hx.keydown_event()])], [])
```

#### `mouseover_event() -> Event`
```gleam
div([hx.get("/api/hover-data"), hx.trigger([hx.mouseover_event()])], [...])
```

#### `mouseout_event() -> Event`
```gleam
div([hx.delete("/api/hover-end"), hx.trigger([hx.mouseout_event()])], [...])
```

#### `scroll_event() -> Event`
```gleam
div([hx.get("/api/scroll-data"), hx.trigger([hx.scroll_event()])], [...])
```

#### `resize_event() -> Event`
```gleam
div([hx.get("/api/resize-data"), hx.trigger([hx.resize_event()])], [...])
```

#### `load_event() -> Event`
Fires when element loads.
```gleam
img([hx.post("/api/image-loaded"), hx.trigger([hx.load_event()])], [])
```

#### `dom_content_loaded_event() -> Event`
```gleam
div([hx.get("/api/init"), hx.trigger([hx.dom_content_loaded_event()])], [...])
```

### HTMX Lifecycle Events

Events that fire during HTMX request lifecycle.

#### Request Lifecycle
- `htmx_before_request_event() -> Event` - Before request is made
- `htmx_after_request_event() -> Event` - After request completes
- `htmx_config_request_event() -> Event` - Before request is configured

#### Content Swap Lifecycle
- `htmx_before_swap_event() -> Event` - Before content swap
- `htmx_after_swap_event() -> Event` - After content swap
- `htmx_before_settle_event() -> Event` - Before settling
- `htmx_after_settle_event() -> Event` - After settling
- `htmx_load_event() -> Event` - When new content loads

#### Error Events
- `htmx_response_error_event() -> Event` - HTTP error response
- `htmx_send_error_event() -> Event` - Network error
- `htmx_timeout_event() -> Event` - Request timeout

#### Validation Events
- `htmx_validation_validate_event() -> Event` - Validation runs
- `htmx_validation_failed_event() -> Event` - Validation fails
- `htmx_validation_halted_event() -> Event` - Validation halted

#### XHR Events
- `htmx_xhr_abort_event() -> Event` - Request aborted
- `htmx_xhr_loadend_event() -> Event` - Request load ends
- `htmx_xhr_loadstart_event() -> Event` - Request load starts
- `htmx_xhr_progress_event() -> Event` - Request progress

### Intersect Events

Viewport intersection observer events.

#### `intersect_event(options: Option(String)) -> Event`
Fires when element enters/exits viewport.

```gleam
// Basic intersection
hx.trigger([hx.intersect_event(None)])

// With root margin options
hx.trigger([hx.intersect_event(Some("10px"))])
```

#### `intersect_once_event(options: Option(String)) -> Event`
Fires only once when element intersects viewport.

```gleam
// Infinite scroll trigger
hx.trigger([hx.intersect_once_event(None)])
```

### Event Modifiers

Functions to modify events with additional behavior.

#### `with_delay(event: Event, timing: Timing) -> Event`
Adds delay before event fires.

```gleam
hx.click_event()
|> hx.with_delay(hx.Seconds(2))
```

#### `with_throttle(event: Event, timing: Timing) -> Event`
Throttles event firing rate.

```gleam
hx.input_event()
|> hx.with_throttle(hx.Milliseconds(300))
```

#### `with_once(event: Event) -> Event`
Event fires only once.

```gleam
hx.click_event()
|> hx.with_once
```

#### `with_changed(event: Event) -> Event`
Only fires when value actually changes.

```gleam
hx.change_event()
|> hx.with_changed
```

#### `with_from(event: Event, extended_css_selector: ExtendedCssSelector) -> Event`
Listen for event from different element.

```gleam
hx.click_event()
|> hx.with_from(hx.Document)
```

#### `with_target(event: Event, css_selector: String) -> Event`
Target different element for event.

```gleam
hx.click_event()
|> hx.with_target("#result")
```

#### `with_consume(event: Event) -> Event`
Prevents event bubbling.

```gleam
hx.click_event()
|> hx.with_consume
```

#### `with_queue(event: Event, queue: Option(Queue)) -> Event`
Queues the event.

```gleam
hx.click_event()
|> hx.with_queue(Some(hx.First))
```

### Polling

#### `trigger_polling(timing: Timing, filters: Option(String)) -> Attribute(msg)`
Creates polling trigger.

```gleam
// Poll every 5 seconds
hx.trigger_polling(hx.Seconds(5), None)

// Poll only when visible
hx.trigger_polling(hx.Seconds(10), Some("intersect"))
```

#### `trigger_load_polling(timing: Timing, filters: String) -> Attribute(msg)`
Triggers on load, then polls.

```gleam
hx.trigger_load_polling(hx.Seconds(3), "intersect")
```

### Core Trigger Function

#### `trigger(events: List(Event)) -> Attribute(msg)`
Sets custom trigger events.

```gleam
// Multiple events
hx.trigger([hx.click_event(), hx.keyup_event()])

// Complex event with modifiers
hx.trigger([
  hx.input_event()
  |> hx.with_throttle(hx.Milliseconds(300))
  |> hx.with_changed
])
```

#### `custom_event(event_name: String) -> Event`
Creates custom event.

```gleam
hx.trigger([hx.custom_event("myCustomEvent")])
```

## Content Targeting & Swapping

### `target(extended_css_selector: ExtendedCssSelector) -> Attribute(msg)`
Specifies target element for content swap.

```gleam
// CSS selector
hx.target(hx.CssSelector("#result"))

// Special selectors
hx.target(hx.This)
hx.target(hx.Closest(".card"))
hx.target(hx.Find(".item"))
hx.target(hx.Document)
hx.target(hx.Window)
hx.target(hx.Next(Some(".sibling")))
hx.target(hx.Previous(None))
```

### `swap(swap: Swap, with_option: Option(SwapOption)) -> Attribute(msg)`
Controls how content is swapped.

**Swap strategies:**
- `hx.InnerHTML` - Replace inner content (default)
- `hx.OuterHTML` - Replace entire element
- `hx.After` - Insert after element
- `hx.Afterbegin` - Insert at beginning of element
- `hx.Beforebegin` - Insert before element
- `hx.Beforeend` - Insert at end of element
- `hx.Afterend` - Insert after element ends
- `hx.Delete` - Delete element
- `hx.SwapNone` - No swapping

**Swap options:**
- `hx.Transition(Bool)` - Enable/disable transitions
- `hx.Swap(Timing)` - Swap timing
- `hx.Settle(Timing)` - Settle timing
- `hx.IgnoreTitle(Bool)` - Ignore title updates
- `hx.Scroll(Scroll)` - Scroll behavior (`hx.Top` or `hx.Bottom`)
- `hx.Show(Scroll)` - Show behavior
- `hx.FocusScroll(Bool)` - Focus scroll behavior

```gleam
// Basic swap
hx.swap(hx.InnerHTML, None)

// With transition
hx.swap(hx.OuterHTML, Some(hx.Transition(True)))

// With scroll
hx.swap(hx.Afterend, Some(hx.Scroll(hx.Top)))
```

### `swap_oob(swap: Swap, with_css_selector: Option(String), with_modifier: Option(SwapOption)) -> Attribute(msg)`
Out-of-band swapping for multiple elements.

```gleam
// Basic OOB swap
hx.swap_oob(hx.InnerHTML, None, None)

// With CSS selector
hx.swap_oob(hx.InnerHTML, Some("#status"), None)

// With modifier
hx.swap_oob(hx.Beforeend, Some("#log"), Some(hx.Scroll(hx.Bottom)))
```

## Request Control

### `sync(synchronize_on: List(SyncOption)) -> Attribute(msg)`
Synchronizes requests.

**Sync options:**
- `hx.Default(css_selector)` - Default sync
- `hx.Drop(css_selector)` - Drop previous requests
- `hx.Abort(css_selector)` - Abort previous requests
- `hx.Replace(css_selector)` - Replace previous requests
- `hx.SyncQueue(css_selector, queue)` - Queue requests

```gleam
hx.sync([hx.Drop("#form"), hx.SyncQueue("#queue", hx.First)])
```

### `headers(headers: json.Json, compute_value: Bool) -> Attribute(msg)`
Adds custom headers.

```gleam
// Static headers
hx.headers(
  json.object([#("Authorization", json.string("Bearer token"))]),
  False
)

// Dynamic headers (JavaScript)
hx.headers(
  json.object([#("X-Token", json.string("getToken()"))]),
  True
)
```

### `vals(json: json.Json, compute_value: Bool) -> Attribute(msg)`
Adds values to request.

```gleam
// Static values
hx.vals(
  json.object([#("user_id", json.string("123"))]),
  False
)

// Dynamic values
hx.vals(
  json.object([#("timestamp", json.string("Date.now()"))]),
  True
)
```

### `request(request: String) -> Attribute(msg)`
Configures request options.

```gleam
hx.request("{timeout:10000, showProgress:true}")
```

### `encoding(encoding: String) -> Attribute(msg)`
Sets request encoding.

```gleam
// For file uploads
hx.encoding("multipart/form-data")
```

## User Experience

### Loading States

#### `indicator(css_selector_or_closest: String) -> Attribute(msg)`
Shows loading indicator.

```gleam
hx.indicator(".loading-spinner")
```

#### `disable_elt(extended_css_selectors: List(ExtendedCssSelector)) -> Attribute(msg)`
Disables elements during request.

```gleam
hx.disable_elt([hx.CssSelector("button"), hx.This])
```

### User Confirmation

#### `confirm(confirm_text: String) -> Attribute(msg)`
Shows confirmation dialog.

```gleam
hx.confirm("Are you sure you want to delete this item?")
```

#### `prompt(prompt_text: String) -> Attribute(msg)`
Shows prompt dialog for input.

```gleam
hx.prompt("Please enter a reason for deletion:")
```

### Navigation

#### `push_url(bool: Bool) -> Attribute(msg)`
Controls URL pushing to browser history.

```gleam
hx.push_url(True)  // Add to history
hx.push_url(False) // Don't add to history
```

#### `replace_url() -> Attribute(msg)`
Replaces current URL.

```gleam
hx.replace_url()
```

#### `no_replace_url() -> Attribute(msg)`
Prevents URL replacement.

```gleam
hx.no_replace_url()
```

#### `replace_url_with(url: String) -> Attribute(msg)`
Replaces URL with specific value.

```gleam
hx.replace_url_with("/new-path")
```

#### `boost(set: Bool) -> Attribute(msg)`
Progressive enhancement for links and forms.

```gleam
hx.boost(True)  // Enable AJAX for all links/forms in element
```

## Form Handling

### `params(params: String) -> Attribute(msg)`
Controls which parameters are sent.

```gleam
hx.params("username,email")    // Include only these
hx.params("not password")      // Exclude password
hx.params("none")             // No parameters
```

### `include(extended_css_selector: ExtendedCssSelector) -> Attribute(msg)`
Includes additional form data.

```gleam
hx.include(hx.CssSelector("#extra-form"))
```

### `validate(bool: Bool) -> Attribute(msg)`
Controls HTML5 validation.

```gleam
hx.validate(True)   // Enable validation
hx.validate(False)  // Skip validation
```

## Advanced Features

### Selection

#### `select(css_selector: String) -> Attribute(msg)`
Selects part of response.

```gleam
hx.select("#content")  // Only use #content from response
```

#### `select_oob(css_selector: String, swap_strategies: List(Swap)) -> Attribute(msg)`
Out-of-band selection.

```gleam
// Basic selection
hx.select_oob(".status", [])

// With swap strategies
hx.select_oob(".data", [hx.InnerHTML, hx.OuterHTML])
```

### State Management

#### `preserve() -> Attribute(msg)`
Preserves element state during swaps.

```gleam
input([hx.preserve()], []) // Keep input value during parent updates
```

#### `history_elt() -> Attribute(msg)`
Marks element for browser history.

```gleam
div([hx.history_elt()], [...]) // Save this content in history
```

#### `history(should_be_saved: Bool) -> Attribute(msg)`
Controls history saving.

```gleam
hx.history(True)   // Save in history
hx.history(False)  // Don't save
```

### Inheritance Control

#### `disinherit(attributes: List(String)) -> Attribute(msg)`
Prevents inheriting specific attributes.

```gleam
hx.disinherit(["hx-trigger", "hx-target"])
```

#### `disinherit_all() -> Attribute(msg)`
Prevents inheriting all attributes.

```gleam
hx.disinherit_all()
```

#### `inherit(attributes: List(String)) -> Attribute(msg)`
Explicitly inherits specific attributes.

```gleam
hx.inherit(["hx-trigger"])
```

#### `inherit_all() -> Attribute(msg)`
Explicitly inherits all attributes.

```gleam
hx.inherit_all()
```

### Extensions & Scripts

#### `ext(ext: List(String)) -> Attribute(msg)`
Includes HTMX extensions.

```gleam
hx.ext(["client-side-templates", "json-enc"])
```

#### `hyper_script(script: String) -> Attribute(msg)`
Adds hyperscript (uses `_` attribute).

```gleam
hx.hyper_script("on click toggle .active on me")
```

#### `disable() -> Attribute(msg)`
Disables HTMX processing.

```gleam
hx.disable() // This element ignores HTMX
```

## Types

### `Timing`
```gleam
pub type Timing {
  Seconds(Int)
  Milliseconds(Int)
}
```

### `Swap`
```gleam
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
```

### `ExtendedCssSelector`
```gleam
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
```

### `Event`
```gleam
pub type Event {
  Event(event: String, modifiers: List(EventModifier))
}
```

### `EventModifier`
```gleam
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
```

### `Queue`
```gleam
pub type Queue {
  First
  Last
  All
}
```

### `SyncOption`
```gleam
pub type SyncOption {
  Default(css_selector: String)
  Drop(css_selector: String)
  Abort(css_selector: String)
  Replace(css_selector: String)
  SyncQueue(css_selector: String, queue: Queue)
}
```

### `SwapOption`
```gleam
pub type SwapOption {
  Transition(Bool)
  Swap(Timing)
  Settle(Timing)
  IgnoreTitle(Bool)
  Scroll(Scroll)
  Show(Scroll)
  FocusScroll(Bool)
}
```

### `Scroll`
```gleam
pub type Scroll {
  Top
  Bottom
}
```