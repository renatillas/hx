# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0]

### Added

#### Modular Architecture

- **Module Organization**: Refactored codebase into focused, modular structure
  - `hx/event` - Event creation and modification functions
  - `hx/attribute` - HTMX attribute types and utilities
  - `hx/css_selector` - Extended CSS selector types and utilities
  - `hx/timing` - Timing specification for delays, throttling, and polling
  - `hx/queue` - Queue behavior types for request synchronization
- **Improved Type Safety**: Enhanced type definitions across all modules
- **Better Code Organization**: Logical separation of concerns for easier maintenance and discovery

#### API Improvements  

- **Simplified Event API**: Cleaner event function names without `_event` suffix in `hx/event` module
  - `event.click()` instead of `hx.click_event()`
  - `event.input()` instead of `hx.input_event()`
  - All HTMX events follow the same pattern
- **Opaque Types**: Enhanced type safety with opaque Event type preventing direct construction
- **Enhanced Documentation**: Comprehensive function documentation with examples for all public APIs  
- **Modular Imports**: Users can import only the modules they need, reducing bundle size

#### HTMX Events Functionality

- **Common DOM Events**: Pre-defined functions for standard DOM events in `hx/event` module
  - `click()` - Creates a click event
  - `change()` - Creates a change event (useful for form inputs)
  - `submit()` - Creates a submit event (useful for forms)
  - `load()` - Creates a load event that fires when the element loads
  - `dom_content_loaded()` - Creates a DOMContentLoaded event
  - `input()` - Creates an input event (fires on every character input)
  - `focus()` - Creates a focus event
  - `blur()` - Creates a blur event
  - `keyup()` - Creates a keyup event
  - `keydown()` - Creates a keydown event
  - `mouseover()` - Creates a mouseover event
  - `mouseout()` - Creates a mouseout event
  - `scroll()` - Creates a scroll event
  - `resize()` - Creates a resize event

#### HTMX-Specific Events

- **Request Lifecycle Events**:
  - `htmx_before_request()` - Fires before an HTMX request is made
  - `htmx_after_request()` - Fires after an HTMX request completes
  - `htmx_config_request()` - Fires before a request is configured, allows modification

- **Content Swap Events**:
  - `htmx_before_swap()` - Fires before content is swapped into the DOM
  - `htmx_after_swap()` - Fires after content has been swapped into the DOM
  - `htmx_before_settle()` - Fires before the settling phase of HTMX
  - `htmx_after_settle()` - Fires after the settling phase of HTMX
  - `htmx_load()` - Fires when new content has been loaded into the DOM by HTMX

- **Error Handling Events**:
  - `htmx_response_error()` - Fires when an HTTP error response is received
  - `htmx_send_error()` - Fires when a network error occurs
  - `htmx_timeout()` - Fires when a request times out

- **Validation Events**:
  - `htmx_validation_validate()` - Fires when validation is run on a form
  - `htmx_validation_failed()` - Fires when validation fails on a form
  - `htmx_validation_halted()` - Fires when validation is halted

- **XHR Events**:
  - `htmx_xhr_abort()` - Fires when a request is aborted
  - `htmx_xhr_loadend()` - Fires when a request load ends
  - `htmx_xhr_loadstart()` - Fires when a request load starts
  - `htmx_xhr_progress()` - Fires during request progress

#### Intersect Events

- `intersect(options)` - Creates an intersect event that fires when element enters/exits the viewport
- `intersect_once(options)` - Creates an intersect event that fires only once

#### Event Helper Functions

- `custom(event_name)` - Creates a custom event with the given name
- `with_delay(event, timing)` - Adds a delay modifier to an existing event
- `with_throttle(event, timing)` - Adds a throttle modifier to an existing event
- `with_once(event)` - Adds a once modifier to an existing event (fires only once)
- `with_changed(event)` - Adds a changed modifier to an existing event
- `with_from(event, extended_css_selector)` - Adds a from modifier to an existing event
- `with_target(event, css_selector)` - Adds a target modifier to an existing event
- `with_consume(event)` - Adds a consume modifier to an existing event
- `with_queue(event, queue)` - Adds a queue modifier to an existing event

#### Testing

- Added comprehensive test suite for all new HTMX events functionality
- Tests cover basic event creation, HTMX-specific events, event modifiers, chained modifiers, and mixed event combinations
- All tests pass successfully ensuring reliability of the new features

### Breaking Changes

- **Event API**: Function names in the `hx/event` module changed from `*_event()` to `*()` (shorter names)
  - Migration: `import hx/event` and use `event.click()` instead of `hx.click_event()`
- **Module Imports**: Event functions moved from main `hx` module to `hx/event` module
  - Migration: Add `import hx/event` and update function calls accordingly
- **Opaque Types**: Event and EventModifier types are now opaque for enhanced type safety
  - Migration: Use provided constructor functions instead of direct type construction

### Migration Guide

```gleam
// Before (v2.0.0)
import hx
hx.trigger([hx.click_event(), hx.input_event()])

// After (v2.1.0)
import hx
import hx/event
hx.trigger([event.click(), event.input()])
```

### Notes

- **Enhanced Type Safety**: Opaque types prevent invalid direct construction
- **Better Organization**: Modular structure improves discoverability and maintainability
- **Documentation**: All functions include comprehensive documentation with examples
- **Ergonomic API**: Event helper functions enable fluent, chainable event configuration

## [2.0.0] - Previous Release

_Previous changelog entries would go here_

