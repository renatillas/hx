# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### HTMX Events Functionality
- **Common DOM Events**: Pre-defined functions for standard DOM events
  - `click_event()` - Creates a click event
  - `change_event()` - Creates a change event (useful for form inputs)
  - `submit_event()` - Creates a submit event (useful for forms)
  - `load_event()` - Creates a load event that fires when the element loads
  - `dom_content_loaded_event()` - Creates a DOMContentLoaded event
  - `input_event()` - Creates an input event (fires on every character input)
  - `focus_event()` - Creates a focus event
  - `blur_event()` - Creates a blur event
  - `keyup_event()` - Creates a keyup event
  - `keydown_event()` - Creates a keydown event
  - `mouseover_event()` - Creates a mouseover event
  - `mouseout_event()` - Creates a mouseout event
  - `scroll_event()` - Creates a scroll event
  - `resize_event()` - Creates a resize event

#### HTMX-Specific Events
- **Request Lifecycle Events**:
  - `htmx_before_request_event()` - Fires before an HTMX request is made
  - `htmx_after_request_event()` - Fires after an HTMX request completes
  - `htmx_config_request_event()` - Fires before a request is configured, allows modification

- **Content Swap Events**:
  - `htmx_before_swap_event()` - Fires before content is swapped into the DOM
  - `htmx_after_swap_event()` - Fires after content has been swapped into the DOM
  - `htmx_before_settle_event()` - Fires before the settling phase of HTMX
  - `htmx_after_settle_event()` - Fires after the settling phase of HTMX
  - `htmx_load_event()` - Fires when new content has been loaded into the DOM by HTMX

- **Error Handling Events**:
  - `htmx_response_error_event()` - Fires when an HTTP error response is received
  - `htmx_send_error_event()` - Fires when a network error occurs
  - `htmx_timeout_event()` - Fires when a request times out

- **Validation Events**:
  - `htmx_validation_validate_event()` - Fires when validation is run on a form
  - `htmx_validation_failed_event()` - Fires when validation fails on a form
  - `htmx_validation_halted_event()` - Fires when validation is halted

- **XHR Events**:
  - `htmx_xhr_abort_event()` - Fires when a request is aborted
  - `htmx_xhr_loadend_event()` - Fires when a request load ends
  - `htmx_xhr_loadstart_event()` - Fires when a request load starts
  - `htmx_xhr_progress_event()` - Fires during request progress

#### Intersect Events
- `intersect_event(options)` - Creates an intersect event that fires when element enters/exits the viewport
- `intersect_once_event(options)` - Creates an intersect event that fires only once

#### Event Helper Functions
- `custom_event(event_name)` - Creates a custom event with the given name
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

### Notes
- **No Breaking Changes**: All additions are backward compatible with v2.0.0
- **Type Safety**: All new functions maintain type safety consistent with the existing codebase
- **Documentation**: All new functions include comprehensive documentation with examples
- **Ergonomic API**: Event helper functions enable fluent, chainable event configuration

## [2.0.0] - Previous Release

_Previous changelog entries would go here_