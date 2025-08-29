# HX

[![Package Version](https://img.shields.io/hexpm/v/hx)](https://hex.pm/packages/hx)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/hx/)

HX is a comprehensive Gleam package that provides complete HTMX integration for the Lustre web framework. It allows you to easily add HTMX attributes to your Lustre HTML elements, enabling dynamic, AJAX-powered web applications with minimal JavaScript.

## Installation

Add `hx` to your Gleam project:

```sh
gleam add hx
```

## Quick Start

```gleam
import hx
import hx/event
import hx/timing
import lustre/element.{button, div, input, text}

pub fn main() {
  div([], [
    // Simple GET request
    button([hx.get("/example")], [text("Load Content")]),
    
    // POST with custom trigger event
    button([
      hx.post("/api/save"), 
      hx.trigger([event.click()])
    ], [text("Save Data")]),
    
    // Input with throttled requests
    input([
      hx.get("/search"), 
      hx.trigger([event.with_throttle(event.input(), timing.Milliseconds(300))])
    ], [])
  ])
}
```

## Core Features

### 🌐 HTTP Method Attributes
Complete support for all HTTP methods:
- `hx.get(url)` - GET requests
- `hx.post(url)` - POST requests  
- `hx.put(url)` - PUT requests
- `hx.patch(url)` - PATCH requests
- `hx.delete(url)` - DELETE requests

### ⚡ Event System
**Pre-defined Events** - Type-safe event functions in the `hx/event` module:
```gleam
import hx/event

// Common DOM events
event.click()
event.change()
event.submit()
event.input()
event.focus()
event.blur()
// ... and more

// HTMX lifecycle events
event.htmx_before_request()
event.htmx_after_request()
event.htmx_before_swap()
event.htmx_after_swap()
// ... and more
```

**Event Modifiers** - Chain modifiers for complex behavior:
```gleam
import hx/event
import hx/timing

event.click()
|> event.with_delay(timing.Seconds(1))
|> event.with_once()
|> event.with_throttle(timing.Milliseconds(500))
```

**Intersection Observer** - Viewport-based triggers:
```gleam
import hx/event

hx.trigger([event.intersect(Some("10px"))])
hx.trigger([event.intersect_once(None)])
```

### 🎯 Content Targeting & Swapping
Precise control over where and how content is updated:
```gleam
import hx/css_selector
import hx/attribute

// Target specific elements
hx.target(css_selector.CssSelector("#result"))
hx.target(css_selector.Closest(".card"))
hx.target(css_selector.This)

// Control swapping behavior
hx.swap(attribute.InnerHTML)
hx.swap_with(attribute.OuterHTML, attribute.Transition(True))
hx.swap_oob(attribute.Beforeend, Some("#log"))
```

### 🔄 Advanced Request Control
**Synchronization**:
```gleam
import hx/attribute
import hx/queue

hx.sync([attribute.Drop("#form"), attribute.SyncQueue("#queue", queue.First)])
```

**Headers & Values**:
```gleam
hx.headers(json.object([#("Authorization", json.string("Bearer token"))]), False)
hx.vals(json.object([#("user_id", json.string("123"))]), False)
```

**Request Configuration**:
```gleam
hx.request("{timeout:10000, showProgress:true}")
hx.encoding("multipart/form-data")
```

### 🛡️ User Experience Features
**Loading States**:
```gleam
import hx/css_selector

hx.indicator(".loading-spinner")
hx.disable_elt([css_selector.CssSelector("button")])
```

**User Confirmation**:
```gleam
hx.confirm("Are you sure you want to delete this item?")
hx.prompt("Please enter a reason:")
```

**Navigation**:
```gleam
hx.push_url(True)
hx.replace_url_with("/new-path")
hx.boost(True)  // Progressive enhancement
```

### 📝 Form Handling
**Parameter Control**:
```gleam
import hx/css_selector

hx.params("username,email")  // Include only specific fields
hx.params("not password")    // Exclude sensitive fields
hx.include(css_selector.CssSelector("#extra-data"))
```

**Validation**:
```gleam
import hx/event

hx.validate(True)  // Enable HTML5 validation
hx.trigger([event.htmx_validation_failed()])
```

### 🎨 Client-Side Interactivity
**Hyperscript Integration**:
```gleam
hx.hyper_script("on click toggle .active on me")
hx.hyper_script("on load wait 3s then add .hidden")
```

**State Preservation**:
```gleam
hx.preserve()  // Keep element state during swaps
hx.history_elt()  // Mark for browser history
```

### 🔧 Advanced Configuration
**Inheritance Control**:
```gleam
hx.disinherit(["hx-trigger", "hx-target"])
hx.disinherit_all()
hx.inherit(["hx-swap"])
hx.inherit_all()
```

**Extensions**:
```gleam
hx.ext(["client-side-templates", "json-enc"])
```

## Event Examples

### Basic Events
```gleam
import hx/event

// Simple click trigger
hx.trigger([event.click()])

// Multiple events
hx.trigger([event.click(), event.keyup()])

// Custom events
hx.trigger([event.custom("myEvent")])
```

### Event Modifiers
```gleam
import hx/event
import hx/timing
import hx/css_selector

// Delayed execution
hx.trigger([event.with_delay(event.click(), timing.Seconds(2))])

// Throttled input
hx.trigger([event.with_throttle(event.input(), timing.Milliseconds(300))])

// Fire only once
hx.trigger([event.with_once(event.click())])

// Only on value change
hx.trigger([event.with_changed(event.input())])

// Listen from different element
hx.trigger([event.with_from(event.click(), css_selector.Document)])
```

### HTMX Lifecycle Events
```gleam
import hx/event

// Before request processing
hx.trigger([event.htmx_before_request()])

// After content swap
hx.trigger([event.htmx_after_swap()])

// Error handling
hx.trigger([event.htmx_response_error()])
```

### Polling
```gleam
import hx/timing

// Simple polling
hx.trigger_polling(timing.Seconds(5), None, False)

// Conditional polling
hx.trigger_polling(timing.Seconds(10), Some("intersect"), False)

// Load + polling
hx.trigger_polling(timing.Seconds(2), None, True)
```

## Real-World Examples

### Search with Debouncing
```gleam
import hx/event
import hx/timing
import hx/css_selector

input([
  type_("text"),
  name("search"),
  hx.get("/api/search"),
  hx.trigger([event.with_throttle(event.input(), timing.Milliseconds(300))]),
  hx.target(css_selector.CssSelector("#search-results"))
], [])
```

### Infinite Scroll
```gleam
import hx/event
import hx/attribute
import hx/css_selector

div([
  hx.get("/api/more-items"),
  hx.trigger([event.intersect_once(None)]),
  hx.swap(attribute.Afterend),
  hx.target(css_selector.This)
], [text("Loading more...")])
```

### Form with Loading State
```gleam
import hx/css_selector

form([
  hx.post("/api/submit"),
  hx.disable_elt([css_selector.CssSelector("button")]),
  hx.indicator(".loading-spinner")
], [
  input([type_("text"), name("name")], []),
  button([type_("submit")], [text("Submit")]),
  div([class("loading-spinner hidden")], [text("Submitting...")])
])
```

### Real-time Updates
```gleam
import hx/timing
import hx/attribute

div([
  hx.get("/api/status"),
  hx.trigger_polling(timing.Seconds(5), None, False),
  hx.swap(attribute.InnerHTML)
], [text("Status: Loading...")])
```

## Documentation

For detailed documentation and examples, visit [hexdocs.pm/hx](https://hexdocs.pm/hx/).

## Contributing

We welcome contributions! Please see our [contributing guidelines](CONTRIBUTING.md) for details.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests (32 tests covering all functionality)
gleam shell # Run an Erlang shell
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
