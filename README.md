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
import lustre/element.{button, div, input, text}

pub fn main() {
  div([], [
    // Simple GET request
    button([hx.get("/example")], [text("Load Content")]),
    
    // POST with custom trigger event
    button([
      hx.post("/api/save"), 
      hx.trigger([hx.click_event()])
    ], [text("Save Data")]),
    
    // Input with throttled requests
    input([
      hx.get("/search"), 
      hx.trigger([hx.with_throttle(hx.input_event(), hx.Milliseconds(300))])
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
**Pre-defined Events** - Type-safe event functions:
```gleam
// Common DOM events
hx.click_event()
hx.change_event()
hx.submit_event()
hx.input_event()
hx.focus_event()
hx.blur_event()
// ... and more

// HTMX lifecycle events
hx.htmx_before_request_event()
hx.htmx_after_request_event()
hx.htmx_before_swap_event()
hx.htmx_after_swap_event()
// ... and more
```

**Event Modifiers** - Chain modifiers for complex behavior:
```gleam
hx.click_event()
|> hx.with_delay(hx.Seconds(1))
|> hx.with_once
|> hx.with_throttle(hx.Milliseconds(500))
```

**Intersection Observer** - Viewport-based triggers:
```gleam
hx.trigger([hx.intersect_event(Some("10px"))])
hx.trigger([hx.intersect_once_event(None)])
```

### 🎯 Content Targeting & Swapping
Precise control over where and how content is updated:
```gleam
// Target specific elements
hx.target(hx.CssSelector("#result"))
hx.target(hx.Closest(".card"))
hx.target(hx.This)

// Control swapping behavior
hx.swap(hx.InnerHTML, None)
hx.swap(hx.OuterHTML, Some(hx.Transition(True)))
hx.swap_oob(hx.Beforeend, Some("#log"), Some(hx.Scroll(hx.Bottom)))
```

### 🔄 Advanced Request Control
**Synchronization**:
```gleam
hx.sync([hx.Drop("#form"), hx.SyncQueue("#queue", hx.First)])
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
hx.indicator(".loading-spinner")
hx.disable_elt([hx.CssSelector("button")])
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
hx.params("username,email")  // Include only specific fields
hx.params("not password")    // Exclude sensitive fields
hx.include(hx.CssSelector("#extra-data"))
```

**Validation**:
```gleam
hx.validate(True)  // Enable HTML5 validation
hx.trigger([hx.htmx_validation_failed_event()])
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
// Simple click trigger
hx.trigger([hx.click_event()])

// Multiple events
hx.trigger([hx.click_event(), hx.keyup_event()])

// Custom events
hx.trigger([hx.custom_event("myEvent")])
```

### Event Modifiers
```gleam
// Delayed execution
hx.trigger([hx.with_delay(hx.click_event(), hx.Seconds(2))])

// Throttled input
hx.trigger([hx.with_throttle(hx.input_event(), hx.Milliseconds(300))])

// Fire only once
hx.trigger([hx.with_once(hx.click_event())])

// Only on value change
hx.trigger([hx.with_changed(hx.input_event())])

// Listen from different element
hx.trigger([hx.with_from(hx.click_event(), hx.Document)])
```

### HTMX Lifecycle Events
```gleam
// Before request processing
hx.trigger([hx.htmx_before_request_event()])

// After content swap
hx.trigger([hx.htmx_after_swap_event()])

// Error handling
hx.trigger([hx.htmx_response_error_event()])
```

### Polling
```gleam
// Simple polling
hx.trigger_polling(hx.Seconds(5), None)

// Conditional polling
hx.trigger_polling(hx.Seconds(10), Some("intersect"))

// Load + polling
hx.trigger_load_polling(hx.Seconds(2), "visible")
```

## Real-World Examples

### Search with Debouncing
```gleam
input([
  type_("text"),
  name("search"),
  hx.get("/api/search"),
  hx.trigger([hx.with_throttle(hx.input_event(), hx.Milliseconds(300))]),
  hx.target(hx.CssSelector("#search-results"))
], [])
```

### Infinite Scroll
```gleam
div([
  hx.get("/api/more-items"),
  hx.trigger([hx.intersect_once_event(None)]),
  hx.swap(hx.Afterend, None),
  hx.target(hx.This)
], [text("Loading more...")])
```

### Form with Loading State
```gleam
form([
  hx.post("/api/submit"),
  hx.disable_elt([hx.CssSelector("button")]),
  hx.indicator(".loading-spinner")
], [
  input([type_("text"), name("name")], []),
  button([type_("submit")], [text("Submit")]),
  div([class("loading-spinner hidden")], [text("Submitting...")])
])
```

### Real-time Updates
```gleam
div([
  hx.get("/api/status"),
  hx.trigger_polling(hx.Seconds(5), None),
  hx.swap(hx.InnerHTML, None)
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
