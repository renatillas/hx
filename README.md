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
import gleam/time/duration
import hx
import lustre/element.{button, div, input, text}

pub fn main() {
  div([], [
    // Simple GET request
    button([hx.get(url: "/example")], [text("Load Content")]),

    // POST with custom trigger event
    button([
      hx.post(url: "/api/save"),
      hx.trigger([hx.click()])
    ], [text("Save Data")]),

    // Input with throttled requests
    input([
      hx.get(url: "/search"),
      hx.trigger([hx.with_throttle(hx.input(), duration.milliseconds(300))])
    ], [])
  ])
}
```

## Server-Side Response Headers

HX also provides comprehensive support for HTMX response headers, enabling powerful server-driven interactions:

```gleam
import hx_header
import gleam/json
import wisp

// Simple triggers and redirects
pub fn save_handler(req) {
  let #(name, value) = hx_header.trigger([
    hx_header.SimpleTrigger("reload")
  ])

  wisp.ok()
  |> wisp.set_header(name, value)
  |> wisp.html_body("<div>Saved!</div>")
}

// Detailed events with JSON payload
pub fn notification_handler(req) {
  let details = json.object([
    #("message", json.string("Success!")),
    #("level", json.string("info"))
  ])

  let #(trigger_name, trigger_value) = hx_header.trigger([
    hx_header.DetailedTrigger("showNotification", details)
  ])
  let #(url_name, url_value) = hx_header.push_url("/dashboard")

  wisp.ok()
  |> wisp.set_header(trigger_name, trigger_value)
  |> wisp.set_header(url_name, url_value)
  |> wisp.html_body("<div>Updated</div>")
}

// Client-side redirect with options
pub fn redirect_handler(req) {
  let config =
    hx_header.new_location("/dashboard")
    |> hx_header.target("#main")
    |> hx_header.swap("innerHTML")

  let #(name, value) = hx_header.location_with(config)

  wisp.ok()
  |> wisp.set_header(name, value)
  |> wisp.html_body("")
}
```

### Available Response Headers

- `redirect(url)` - Full page redirect
- `refresh()` - Refresh the page
- `push_url(url)` - Push URL to history
- `replace_url(url)` - Replace URL in history
- `reswap(swap)` - Change swap strategy
- `retarget(selector)` - Change target element
- `reselect(selector)` - Change selected content
- `location(url)` - Client-side redirect
- `location_with(config)` - Client-side redirect with options
- `trigger(events)` - Trigger client-side events
- `trigger_after_swap(events)` - Trigger after swap
- `trigger_after_settle(events)` - Trigger after settle

## Documentation

For detailed documentation and examples, visit [hexdocs.pm/hx](https://hexdocs.pm/hx/).

## Contributing

We welcome contributions! Please open an issue or pull request on GitHub.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
