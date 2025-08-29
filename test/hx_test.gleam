import gleam/json
import gleam/option.{None, Some}
import gleeunit
import hx
import hx/attribute
import hx/css_selector
import hx/event
import hx/queue
import hx/timing
import lustre/vdom/vattr

pub fn main() {
  gleeunit.main()
}

fn assert_attribute(attr: vattr.Attribute(a), name: String, value: String) {
  let assert vattr.Attribute(_, actual_name, actual_value) = attr

  assert actual_name == name

  assert actual_value == value
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
  hx.trigger([event.click()])
  |> assert_attribute("hx-trigger", "click")

  hx.trigger([event.keyup() |> event.with_once()])
  |> assert_attribute("hx-trigger", "keyup once")

  // Multiple events
  hx.trigger([event.click(), event.keyup() |> event.with_once()])
  |> assert_attribute("hx-trigger", "click, keyup once")
}

pub fn timing_test() {
  let seconds = timing.Seconds(5)
  assert seconds
    |> timing.to_string
    == "5s"

  // Test Milliseconds
  let milliseconds = timing.Milliseconds(500)
  assert milliseconds
    |> timing.to_string
    == "500ms"
}

pub fn trigger_polling_test() {
  // Without filters
  hx.trigger_polling(timing: timing.Seconds(2), filters: None, on_load: False)
  |> assert_attribute("hx-trigger", "every 2s")

  // With filters
  hx.trigger_polling(
    timing: timing.Milliseconds(500),
    filters: Some("this.value.length > 3"),
    on_load: False,
  )
  |> assert_attribute("hx-trigger", "every 500ms [this.value.length > 3]")
}

pub fn trigger_load_polling_test() {
  hx.trigger_polling(
    timing: timing.Seconds(5),
    filters: Some("when_visible"),
    on_load: True,
  )
  |> assert_attribute("hx-trigger", "load every 5s [when_visible]")
}

pub fn indicator_test() {
  hx.indicator(css_selector_or_closest: ".loading")
  |> assert_attribute("hx-indicator", ".loading")
}

pub fn target_test() {
  // Test CssSelector
  hx.target(extended_css_selector: css_selector.CssSelector("#result"))
  |> assert_attribute("hx-target", "#result")

  // Test This
  hx.target(extended_css_selector: css_selector.This)
  |> assert_attribute("hx-target", "this")

  // Test Document
  hx.target(extended_css_selector: css_selector.Document)
  |> assert_attribute("hx-target", "document")

  // Test Window
  hx.target(extended_css_selector: css_selector.Window)
  |> assert_attribute("hx-target", "window")

  // Test Closest
  hx.target(extended_css_selector: css_selector.Closest(".card"))
  |> assert_attribute("hx-target", "closest .card")

  // Test Find
  hx.target(extended_css_selector: css_selector.Find(".item"))
  |> assert_attribute("hx-target", "find .item")

  // Test Next
  hx.target(extended_css_selector: css_selector.Next(".sibling"))
  |> assert_attribute("hx-target", "next .sibling")

  // Test Previous
  hx.target(extended_css_selector: css_selector.Previous(".sibling"))
  |> assert_attribute("hx-target", "previous .sibling")
}

pub fn swap_test() {
  // Without option
  hx.swap(swap: attribute.InnerHTML)
  |> assert_attribute("hx-swap", "innerHTML")

  // With option - Transition
  hx.swap_with(swap: attribute.OuterHTML, config: attribute.Transition(True))
  |> assert_attribute("hx-swap", "outerHTML transition:true")

  // With option - Swap timing
  hx.swap_with(
    swap: attribute.After,
    config: attribute.SwapTiming(timing.Seconds(1)),
  )
  |> assert_attribute("hx-swap", "after swap:1s")

  // With option - Scroll
  hx.swap_with(
    swap: attribute.Beforeend,
    config: attribute.ScrollTo(attribute.Top),
  )
  |> assert_attribute("hx-swap", "beforeEnd scroll:top")

  // With option - Show
  hx.swap_with(swap: attribute.Delete, config: attribute.Show(attribute.Bottom))
  |> assert_attribute("hx-swap", "delete show:bottom")
}

pub fn swap_oob_test() {
  // Basic swap oob
  hx.swap_oob(swap: attribute.InnerHTML, css_selector: None)
  |> assert_attribute("hx-swap-oob", "innerHTML")

  // Swap oob with CSS selector
  hx.swap_oob(swap: attribute.OuterHTML, css_selector: Some("#target"))
  |> assert_attribute("hx-swap-oob", "outerHTML,#target")

  // Swap oob with modifier
  hx.swap_oob_with(
    swap: attribute.After,
    css_selector: None,
    config: attribute.Transition(True),
  )
  |> assert_attribute("hx-swap-oob", "after transition:true")

  // Swap oob with both CSS selector and modifier
  hx.swap_oob_with(
    swap: attribute.Beforeend,
    css_selector: Some(".container"),
    config: attribute.ScrollTo(attribute.Top),
  )
  |> assert_attribute("hx-swap-oob", "beforeEnd,.container scroll:top")
}

pub fn sync_test() {
  // Single sync option
  hx.sync([attribute.Default("#form")])
  |> assert_attribute("hx-sync", "default:#form")

  // Multiple sync options
  hx.sync([attribute.Drop("#form1"), attribute.Abort("#form2")])
  |> assert_attribute("hx-sync", "drop:#form1 abort:#form2")

  // Queue sync option
  hx.sync([attribute.SyncQueue("#form", queue.First)])
  |> assert_attribute("hx-sync", "queue:#form first")
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
  hx.select_oob(".card", [attribute.InnerHTML])
  |> assert_attribute("hx-select", ".card:innerHTML")

  // With multiple swap strategies
  hx.select_oob(".container", [
    attribute.OuterHTML,
    attribute.After,
    attribute.Delete,
  ])
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
  hx.disable_elt([css_selector.CssSelector(".form-input")])
  |> assert_attribute("hx-disable-elt", ".form-input")

  // Multiple selectors
  hx.disable_elt([
    css_selector.CssSelector(".btn"),
    css_selector.Closest(".form"),
    css_selector.This,
  ])
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

pub fn common_events_test() {
  // Test basic DOM events
  hx.trigger([event.click()])
  |> assert_attribute("hx-trigger", "click")

  hx.trigger([event.change()])
  |> assert_attribute("hx-trigger", "change")

  hx.trigger([event.submit()])
  |> assert_attribute("hx-trigger", "submit")

  hx.trigger([event.load()])
  |> assert_attribute("hx-trigger", "load")

  hx.trigger([event.input()])
  |> assert_attribute("hx-trigger", "input")

  hx.trigger([event.focus()])
  |> assert_attribute("hx-trigger", "focus")

  hx.trigger([event.blur()])
  |> assert_attribute("hx-trigger", "blur")

  hx.trigger([event.keyup()])
  |> assert_attribute("hx-trigger", "keyup")

  hx.trigger([event.keydown()])
  |> assert_attribute("hx-trigger", "keydown")

  hx.trigger([event.mouseover()])
  |> assert_attribute("hx-trigger", "mouseover")

  hx.trigger([event.mouseout()])
  |> assert_attribute("hx-trigger", "mouseout")

  hx.trigger([event.scroll()])
  |> assert_attribute("hx-trigger", "scroll")

  hx.trigger([event.resize()])
  |> assert_attribute("hx-trigger", "resize")

  hx.trigger([event.dom_content_loaded()])
  |> assert_attribute("hx-trigger", "DOMContentLoaded")
}

pub fn htmx_events_test() {
  // Test HTMX-specific events
  hx.trigger([event.htmx_before_request()])
  |> assert_attribute("hx-trigger", "htmx:beforeRequest")

  hx.trigger([event.htmx_after_request()])
  |> assert_attribute("hx-trigger", "htmx:afterRequest")

  hx.trigger([event.htmx_before_swap()])
  |> assert_attribute("hx-trigger", "htmx:beforeSwap")

  hx.trigger([event.htmx_after_swap()])
  |> assert_attribute("hx-trigger", "htmx:afterSwap")

  hx.trigger([event.htmx_before_settle()])
  |> assert_attribute("hx-trigger", "htmx:beforeSettle")

  hx.trigger([event.htmx_after_settle()])
  |> assert_attribute("hx-trigger", "htmx:afterSettle")

  hx.trigger([event.htmx_load()])
  |> assert_attribute("hx-trigger", "htmx:load")

  hx.trigger([event.htmx_config_request()])
  |> assert_attribute("hx-trigger", "htmx:configRequest")

  hx.trigger([event.htmx_response_error()])
  |> assert_attribute("hx-trigger", "htmx:responseError")

  hx.trigger([event.htmx_send_error()])
  |> assert_attribute("hx-trigger", "htmx:sendError")

  hx.trigger([event.htmx_timeout()])
  |> assert_attribute("hx-trigger", "htmx:timeout")

  hx.trigger([event.htmx_validation_validate()])
  |> assert_attribute("hx-trigger", "htmx:validation:validate")

  hx.trigger([event.htmx_validation_failed()])
  |> assert_attribute("hx-trigger", "htmx:validation:failed")

  hx.trigger([event.htmx_validation_halted()])
  |> assert_attribute("hx-trigger", "htmx:validation:halted")

  hx.trigger([event.htmx_xhr_abort()])
  |> assert_attribute("hx-trigger", "htmx:xhr:abort")

  hx.trigger([event.htmx_xhr_loadend()])
  |> assert_attribute("hx-trigger", "htmx:xhr:loadend")

  hx.trigger([event.htmx_xhr_loadstart()])
  |> assert_attribute("hx-trigger", "htmx:xhr:loadstart")

  hx.trigger([event.htmx_xhr_progress()])
  |> assert_attribute("hx-trigger", "htmx:xhr:progress")
}

pub fn intersect_events_test() {
  // Basic intersect event
  hx.trigger([event.intersect(None)])
  |> assert_attribute("hx-trigger", "intersect")

  // Intersect event with once modifier
  hx.trigger([event.intersect_once(None)])
  |> assert_attribute("hx-trigger", "intersect once")

  // Intersect event with options (using from modifier with CSS selector)
  hx.trigger([event.intersect(Some("10px"))])
  |> assert_attribute("hx-trigger", "intersect from:10px")

  // Intersect once with options
  hx.trigger([event.intersect_once(Some("20px 30px"))])
  |> assert_attribute("hx-trigger", "intersect from:20px 30px once")
}

pub fn custom_events_test() {
  // Test custom event creation
  hx.trigger([event.custom("myCustomEvent")])
  |> assert_attribute("hx-trigger", "myCustomEvent")

  // Test multiple custom events
  hx.trigger([event.custom("event1"), event.custom("event2")])
  |> assert_attribute("hx-trigger", "event1, event2")
}

pub fn event_modifiers_test() {
  // Test with_delay modifier
  hx.trigger([event.with_delay(event.click(), timing.Seconds(2))])
  |> assert_attribute("hx-trigger", "click delay:2s")

  // Test with_throttle modifier
  hx.trigger([
    event.with_throttle(event.input(), timing.Milliseconds(300)),
  ])
  |> assert_attribute("hx-trigger", "input throttle:300ms")

  // Test with_once modifier
  hx.trigger([event.with_once(event.click())])
  |> assert_attribute("hx-trigger", "click once")

  // Test with_changed modifier
  hx.trigger([event.with_changed(event.input())])
  |> assert_attribute("hx-trigger", "input changed")

  // Test with_from modifier
  hx.trigger([event.with_from(event.click(), css_selector.Document)])
  |> assert_attribute("hx-trigger", "click from:document")

  // Test with_target modifier
  hx.trigger([event.with_target(event.click(), "#target")])
  |> assert_attribute("hx-trigger", "click target:#target")

  // Test with_consume modifier
  hx.trigger([event.with_consume(event.click())])
  |> assert_attribute("hx-trigger", "click consume")

  // Test with_queue modifier
  hx.trigger([event.with_queue(event.click(), Some(queue.First))])
  |> assert_attribute("hx-trigger", "click queue:first")
}

pub fn chained_event_modifiers_test() {
  // Test chaining multiple modifiers
  let complex_event =
    event.click()
    |> event.with_delay(timing.Milliseconds(100))
    |> event.with_once
    |> event.with_from(css_selector.Window)

  hx.trigger([complex_event])
  |> assert_attribute("hx-trigger", "click from:window once delay:100ms")
}

pub fn multiple_mixed_events_test() {
  // Test combining different types of events
  hx.trigger([
    event.click(),
    event.with_delay(event.keyup(), timing.Seconds(1)),
    event.htmx_after_request(),
    event.intersect_once(None),
  ])
  |> assert_attribute(
    "hx-trigger",
    "click, keyup delay:1s, htmx:afterRequest, intersect once",
  )
}
