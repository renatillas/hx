# Lustre HTMX

[![Package Version](https://img.shields.io/hexpm/v/lustre_htmx)](https://hex.pm/packages/lustre_htmx)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lustre_htmx/)

Lustre HTMX is a Gleam package that provides HTMX integration for the Lustre web framework. It allows you to easily add HTMX attributes to your Lustre HTML elements, enabling dynamic, AJAX-powered web applications with minimal JavaScript.

## Installation

Add `lustre_htmx` to your Gleam project:

```sh
gleam add lustre_hx
```

## Usage

```Gleam
import lustre_hx as hx
import lustre/element.{button, div, text}

pub fn main() {
  div([], [
    // Example: Create a button that loads content via HTMX GET request
    button([hx.get("/example")], [
      text("Get some HTML")
    ])
  ])
}
```

## Features

- HTTP Method Attributes:

  - hx-get: Make GET requests
  - hx-post: Make POST requests
  - hx-put: Make PUT requests
  - hx-patch: Make PATCH requests
  - hx-delete: Make DELETE requests
- Event Handling:
  - hx-trigger: Customize event triggers for HTMX requests

## Documentation

For detailed documentation and examples, visit hexdocs.pm/lustre_htmx.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
