import gleam/dynamic
import gleam/json
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import hx
import lustre/attribute.{type Attribute}
import lustre/internals/vdom.{Attribute}

pub fn main() {
  gleeunit.main()
}

fn assert_attribute(attribute: Attribute(_), name: String, value: String) {
  let assert Attribute(attr_name, attr_value, False) = attribute
  attr_name
  |> should.equal(name)

  attr_value
  |> should.equal(value |> dynamic.from())
}

pub fn get_test() {
  hx.get(url: "/api/data")
  |> assert_attribute("hx-get", "/api/data")
}

pub fn post_test() {
  hx.post(url: "/api/data")
  |> assert_attribute("hx-post", "/api/data")
}

pub fn put_test() {
  hx.put(url: "/api/data")
  |> assert_attribute("hx-put", "/api/data")
}

pub fn patch_test() {
  hx.patch(url: "/api/data")
  |> assert_attribute("hx-patch", "/api/data")
}

pub fn delete_test() {
  hx.delete(url: "/api/data")
  |> assert_attribute("hx-delete", "/api/data")
}

pub fn trigger_test() {
  let click_event = hx.Event(event: "click", modifiers: [])

  hx.trigger([click_event])
  |> assert_attribute("hx-trigger", "click")

  let keyup_event = hx.Event(event: "keyup", modifiers: [hx.Once])

  hx.trigger([keyup_event])
  |> assert_attribute("hx-trigger", "keyup once")

  // Multiple events
  hx.trigger([click_event, keyup_event])
  |> assert_attribute("hx-trigger", "click, keyup once")
}

pub fn timing_test() {
  // Test Seconds
  let seconds = hx.Seconds(5)
  seconds
  |> hx.timing_declaration_to_string
  |> should.equal("5s")

  // Test Milliseconds
  let milliseconds = hx.Milliseconds(500)
  milliseconds
  |> hx.timing_declaration_to_string
  |> should.equal("500ms")
}

pub fn trigger_polling_test() {
  // Without filters
  hx.trigger_polling(timing: hx.Seconds(2), filters: None)
  |> assert_attribute("hx-trigger", "every 2s")

  // With filters
  hx.trigger_polling(
    timing: hx.Milliseconds(500),
    filters: Some("this.value.length > 3"),
  )
  |> assert_attribute("hx-trigger", "every 500ms [this.value.length > 3]")
}

pub fn trigger_load_polling_test() {
  hx.trigger_load_polling(timing: hx.Seconds(5), filters: "when_visible")
  |> assert_attribute("hx-trigger", "load every 5s [when_visible]")
}

pub fn indicator_test() {
  hx.indicator(css_selector_or_closest: ".loading")
  |> assert_attribute("hx-indicator", ".loading")
}

pub fn target_test() {
  // Test CssSelector
  hx.target(extended_css_selector: hx.CssSelector("#result"))
  |> assert_attribute("hx-target", "#result")

  // Test This
  hx.target(extended_css_selector: hx.This)
  |> assert_attribute("hx-target", "this")

  // Test Document
  hx.target(extended_css_selector: hx.Document)
  |> assert_attribute("hx-target", "document")

  // Test Window
  hx.target(extended_css_selector: hx.Window)
  |> assert_attribute("hx-target", "window")

  // Test Closest
  hx.target(extended_css_selector: hx.Closest(".card"))
  |> assert_attribute("hx-target", "closest .card")

  // Test Find
  hx.target(extended_css_selector: hx.Find(".item"))
  |> assert_attribute("hx-target", "find .item")

  // Test Next
  hx.target(extended_css_selector: hx.Next(Some(".sibling")))
  |> assert_attribute("hx-target", "next .sibling")

  // Test Previous
  hx.target(extended_css_selector: hx.Previous(Some(".sibling")))
  |> assert_attribute("hx-target", "previous .sibling")
}

pub fn swap_test() {
  // Without option
  hx.swap(swap: hx.InnerHTML, with_option: None)
  |> assert_attribute("hx-swap", "innerHTML")

  // With option - Transition
  hx.swap(swap: hx.OuterHTML, with_option: Some(hx.Transition(True)))
  |> assert_attribute("hx-swap", "outerHTML transition:true")

  // With option - Swap timing
  hx.swap(swap: hx.After, with_option: Some(hx.Swap(hx.Seconds(1))))
  |> assert_attribute("hx-swap", "after swap:1s")

  // With option - Scroll
  hx.swap(swap: hx.Beforeend, with_option: Some(hx.Scroll(hx.Top)))
  |> assert_attribute("hx-swap", "beforeEnd scroll:top")

  // With option - Show
  hx.swap(swap: hx.Delete, with_option: Some(hx.Show(hx.Bottom)))
  |> assert_attribute("hx-swap", "delete show:bottom")
}

pub fn swap_oob_test() {
  // Basic swap oob
  hx.swap_oob(swap: hx.InnerHTML, with_css_selector: None, with_modifier: None)
  |> assert_attribute("hx-swap-oob", "innerHTML")

  // Swap oob with CSS selector
  hx.swap_oob(
    swap: hx.OuterHTML,
    with_css_selector: Some("#target"),
    with_modifier: None,
  )
  |> assert_attribute("hx-swap-oob", "outerHTML,#target")

  // Swap oob with modifier
  hx.swap_oob(
    swap: hx.After,
    with_css_selector: None,
    with_modifier: Some(hx.Transition(True)),
  )
  |> assert_attribute("hx-swap-oob", "after transition:true")

  // Swap oob with both CSS selector and modifier
  hx.swap_oob(
    swap: hx.Beforeend,
    with_css_selector: Some(".container"),
    with_modifier: Some(hx.Scroll(hx.Top)),
  )
  |> assert_attribute("hx-swap-oob", "beforeEnd,.container scroll:top")
}

pub fn sync_test() {
  // Single sync option
  hx.sync([hx.Default("#form")])
  |> assert_attribute("hx-sync", "#form")

  // Multiple sync options
  hx.sync([hx.Drop("#form1"), hx.Abort("#form2")])
  |> assert_attribute("hx-sync", "#form1:drop #form2:abort")

  // Queue sync option
  hx.sync([hx.SyncQueue("#form", hx.First)])
  |> assert_attribute("hx-sync", "#form:queue first")
}

pub fn select_test() {
  hx.select(".result-item")
  |> assert_attribute("hx-select", ".result-item")
}

pub fn select_oob_test() {
  // Without swap strategies
  hx.select_oob(".result-item", [])
  |> assert_attribute("hx-select", ".result-item")

  // With single swap strategy
  hx.select_oob(".card", [hx.InnerHTML])
  |> assert_attribute("hx-select", ".card:innerHTML")

  // With multiple swap strategies
  hx.select_oob(".container", [hx.OuterHTML, hx.After, hx.Delete])
  |> assert_attribute("hx-select", ".container:outerHTML,after,delete")
}

pub fn push_url_test() {
  hx.push_url(True)
  |> assert_attribute("hx-push-url", "true")

  hx.push_url(False)
  |> assert_attribute("hx-push-url", "false")
}

pub fn confirm_test() {
  hx.confirm("Are you sure you want to delete this item?")
  |> assert_attribute(
    "hx-confirm",
    "Are you sure you want to delete this item?",
  )
}

pub fn boost_test() {
  hx.boost(True)
  |> assert_attribute("hx-boost", "true")

  hx.boost(False)
  |> assert_attribute("hx-boost", "false")
}

pub fn hyper_script_test() {
  hx.hyper_script("on click toggle .active")
  |> assert_attribute("_", "on click toggle .active")
}

pub fn vals_test() {
  // Regular JSON value
  let json_value =
    json.object([#("name", json.string("John")), #("age", json.float(30.0))])

  hx.vals(json_value, False)
  |> assert_attribute("hx-vals", "{\"name\":\"John\",\"age\":30.0}")

  // JavaScript computed value
  hx.vals(json_value, True)
  |> assert_attribute("hx-vals", "js:{\"name\":\"John\",\"age\":30.0}")
}

pub fn disable_test() {
  hx.disable()
  |> assert_attribute("hx-disable", "")
}

pub fn disable_elt_test() {
  // Single selector
  hx.disable_elt([hx.CssSelector(".form-input")])
  |> assert_attribute("hx-disable-elt", ".form-input")

  // Multiple selectors
  hx.disable_elt([hx.CssSelector(".btn"), hx.Closest(".form"), hx.This])
  |> assert_attribute("hx-disable-elt", ".btn,closest .form,this")
}

pub fn disinherit_test() {
  // Single attribute
  hx.disinherit(["hx-target"])
  |> assert_attribute("hx-disinherit", "hx-target")

  // Multiple attributes
  hx.disinherit(["hx-target", "hx-swap", "hx-trigger"])
  |> assert_attribute("hx-disinherit", "hx-target hx-swap hx-trigger")
}

pub fn disinherit_all_test() {
  hx.disinherit_all()
  |> assert_attribute("hx-disinherit", "*")
}
