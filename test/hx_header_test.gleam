import gleam/json
import gleam/option.{None, Some}
import gleeunit
import hx_header

pub fn main() {
  gleeunit.main()
}

// ==== SIMPLE HEADERS TESTS ====

pub fn hx_redirect_test() {
  assert #("HX-Redirect", "/login") == hx_header.redirect("/login")
  assert #("HX-Redirect", "/dashboard") == hx_header.redirect("/dashboard")
}

pub fn hx_refresh_test() {
  assert #("HX-Refresh", "true") == hx_header.refresh()
}

pub fn hx_push_url_test() {
  assert #("HX-Push-Url", "/new-path") == hx_header.push_url("/new-path")
  assert #("HX-Push-Url", "/users/123") == hx_header.push_url("/users/123")
}

pub fn hx_replace_url_test() {
  assert #("HX-Replace-Url", "/updated-path")
    == hx_header.replace_url("/updated-path")
  assert #("HX-Replace-Url", "/posts/456")
    == hx_header.replace_url("/posts/456")
}

pub fn hx_reswap_test() {
  assert #("HX-Reswap", "outerHTML") == hx_header.reswap("outerHTML")
  assert #("HX-Reswap", "innerHTML") == hx_header.reswap("innerHTML")
  assert #("HX-Reswap", "beforebegin") == hx_header.reswap("beforebegin")
  assert #("HX-Reswap", "afterend") == hx_header.reswap("afterend")
}

pub fn hx_retarget_test() {
  assert #("HX-Retarget", "#main") == hx_header.retarget("#main")
  assert #("HX-Retarget", ".content") == hx_header.retarget(".content")
}

pub fn hx_reselect_test() {
  assert #("HX-Reselect", "#content") == hx_header.reselect("#content")
  assert #("HX-Reselect", ".article") == hx_header.reselect(".article")
}

// ==== LOCATION HEADERS TESTS ====

pub fn hx_location_simple_test() {
  assert #("HX-Location", "/dashboard") == hx_header.location("/dashboard")
  assert #("HX-Location", "/users/profile")
    == hx_header.location("/users/profile")
}

pub fn hx_location_with_options_test() {
  let config =
    hx_header.location_config("/dashboard")
    |> hx_header.target("#main")
    |> hx_header.swap("innerHTML")

  assert #(
      "HX-Location",
      "{\"path\":\"/dashboard\",\"target\":\"#main\",\"swap\":\"innerHTML\"}",
    )
    == hx_header.location_with(config)
}

pub fn location_builder_pattern_test() {
  // Test basic location
  let config1 = hx_header.location_config("/page")
  let assert "/page" = config1.path
  let assert None = config1.target
  let assert None = config1.swap

  // Test with target
  let config2 =
    hx_header.location_config("/page")
    |> hx_header.target("#content")
  assert Some("#content") == config2.target

  // Test with swap
  let config3 =
    hx_header.location_config("/page")
    |> hx_header.swap("outerHTML")
  assert Some("outerHTML") == config3.swap

  // Test with event
  let config4 =
    hx_header.location_config("/page")
    |> hx_header.event("click")
  assert Some("click") == config4.event

  // Test with source
  let config5 =
    hx_header.location_config("/page")
    |> hx_header.source("#button")
  assert Some("#button") == config5.source

  // Test with values
  let values = json.object([#("key", json.string("value"))])
  let config6 =
    hx_header.location_config("/page")
    |> hx_header.values(values)
  assert Some(values) == config6.values

  // Test chaining multiple options
  let config7 =
    hx_header.location_config("/dashboard")
    |> hx_header.target("#main")
    |> hx_header.swap("innerHTML")
    |> hx_header.event("click")
    |> hx_header.source("#nav-button")

  assert "/dashboard" == config7.path
  assert Some("#main") == config7.target
  assert Some("innerHTML") == config7.swap
  assert Some("click") == config7.event
  assert Some("#nav-button") == config7.source
}

// ==== TRIGGER HEADERS TESTS ====

pub fn hx_trigger_single_simple_test() {
  assert #("HX-Trigger", "reload")
    == hx_header.trigger([hx_header.SimpleTrigger("reload")])

  assert #("HX-Trigger", "clearForm")
    == hx_header.trigger([hx_header.SimpleTrigger("clearForm")])
}

pub fn hx_trigger_multiple_simple_test() {
  assert #("HX-Trigger", "reload, clearForm")
    == hx_header.trigger([
      hx_header.SimpleTrigger("reload"),
      hx_header.SimpleTrigger("clearForm"),
    ])
}

pub fn hx_trigger_detailed_test() {
  let details =
    json.object([
      #("message", json.string("Success!")),
      #("level", json.string("info")),
    ])
  let expected_details = json.object([#("showNotification", details)])

  assert #("HX-Trigger", expected_details |> json.to_string)
    == hx_header.trigger([
      hx_header.DetailedTrigger("showNotification", details),
    ])
}

pub fn hx_trigger_mixed_test() {
  // When mixing simple and detailed triggers, should use JSON format
  let details = json.object([#("count", json.int(5))])
  let expected_content =
    json.object([
      #("reload", json.null()),
      #("update", details),
    ])

  assert #("HX-Trigger", expected_content |> json.to_string)
    == hx_header.trigger([
      hx_header.SimpleTrigger("reload"),
      hx_header.DetailedTrigger("update", details),
    ])
}

pub fn hx_trigger_empty_test() {
  let assert #("HX-Trigger", "") = hx_header.trigger([])
}

pub fn hx_trigger_after_swap_test() {
  let assert #("HX-Trigger-After-Swap", "highlightNew") =
    hx_header.trigger_after_swap([hx_header.SimpleTrigger("highlightNew")])

  let assert #("HX-Trigger-After-Swap", "reload, update") =
    hx_header.trigger_after_swap([
      hx_header.SimpleTrigger("reload"),
      hx_header.SimpleTrigger("update"),
    ])
}

pub fn hx_trigger_after_settle_test() {
  assert #("HX-Trigger-After-Settle", "scrollToTop")
    == hx_header.trigger_after_settle([hx_header.SimpleTrigger("scrollToTop")])

  let details = json.object([#("position", json.int(0))])
  let expected_details = json.object([#("scroll", details)])

  assert #("HX-Trigger-After-Settle", expected_details |> json.to_string)
    == hx_header.trigger_after_settle([
      hx_header.DetailedTrigger("scroll", details),
    ])
}

// ==== INTEGRATION TESTS ====

pub fn detailed_trigger_with_complex_json_test() {
  let details =
    json.object([
      #("message", json.string("Operation completed")),
      #("level", json.string("success")),
      #(
        "data",
        json.object([#("id", json.int(123)), #("name", json.string("Test"))]),
      ),
      #("items", json.array([1, 2, 3], json.int)),
    ])
  let expected_details = json.object([#("notification", details)])

  assert #("HX-Trigger", expected_details |> json.to_string)
    == hx_header.trigger([hx_header.DetailedTrigger("notification", details)])
}

pub fn multiple_detailed_triggers_test() {
  let details1 = json.object([#("message", json.string("First event"))])
  let details2 = json.object([#("message", json.string("Second event"))])

  let expected_details =
    json.object([
      #("event1", details1),
      #("event2", details2),
    ])

  assert #("HX-Trigger", expected_details |> json.to_string)
    == hx_header.trigger([
      hx_header.DetailedTrigger("event1", details1),
      hx_header.DetailedTrigger("event2", details2),
    ])
}

pub fn location_with_all_options_test() {
  let values =
    json.object([
      #("userId", json.int(123)),
      #("role", json.string("admin")),
    ])

  let config =
    hx_header.location_config("/dashboard")
    |> hx_header.target("#main")
    |> hx_header.swap("innerHTML")
    |> hx_header.event("click")
    |> hx_header.source("#nav-link")
    |> hx_header.values(values)

  let expected_json =
    json.object([
      #("path", json.string("/dashboard")),
      #("source", json.string("#nav-link")),
      #("event", json.string("click")),
      #("target", json.string("#main")),
      #("swap", json.string("innerHTML")),
      #(
        "values",
        json.object([
          #("userId", json.int(123)),
          #("role", json.string("admin")),
        ]),
      ),
    ])

  assert #("HX-Location", expected_json |> json.to_string)
    == hx_header.location_with(config)
}
