import gleam/json
import gleam/option.{None, Some}
import gleam/time/duration
import gleeunit
import hx
import lustre/vdom/vattr

pub fn main() {
  gleeunit.main()
}

fn assert_attribute(attr: vattr.Attribute(a), name: String, value: String) {
  assert vattr.Attribute(0, name, value) == attr
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
  hx.trigger([hx.click()])
  |> assert_attribute("hx-trigger", "click")

  hx.trigger([hx.keyup() |> hx.with_once()])
  |> assert_attribute("hx-trigger", "keyup once")

  // Multiple events
  hx.trigger([hx.click(), hx.keyup() |> hx.with_once()])
  |> assert_attribute("hx-trigger", "click, keyup once")
}

pub fn timing_test() {
  let seconds = hx.duration_to_string(duration.seconds(5))
  assert seconds == "5000ms"

  // Test Milliseconds
  let milliseconds = hx.duration_to_string(duration.milliseconds(500))
  assert milliseconds == "500ms"
}

pub fn trigger_polling_test() {
  // Without filters
  hx.trigger_polling(timing: duration.seconds(2), filters: None, on_load: False)
  |> assert_attribute("hx-trigger", "every 2000ms")

  // With filters
  hx.trigger_polling(
    timing: duration.milliseconds(500),
    filters: Some("this.value.length > 3"),
    on_load: False,
  )
  |> assert_attribute("hx-trigger", "every 500ms [this.value.length > 3]")
}

pub fn trigger_load_polling_test() {
  hx.trigger_polling(
    timing: duration.seconds(5),
    filters: Some("when_visible"),
    on_load: True,
  )
  |> assert_attribute("hx-trigger", "load every 5000ms [when_visible]")
}

pub fn indicator_test() {
  // Test with standard CSS selector
  hx.indicator(hx.Selector(".loading"))
  |> assert_attribute("hx-indicator", ".loading")

  // Test with closest
  hx.indicator(hx.Closest("tr"))
  |> assert_attribute("hx-indicator", "closest tr")

  // Test with this
  hx.indicator(hx.This)
  |> assert_attribute("hx-indicator", "this")
}

pub fn target_test() {
  // Test CssSelector
  hx.target(extended_css_selector: hx.Selector("#result"))
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
  hx.target(extended_css_selector: hx.Next(".sibling"))
  |> assert_attribute("hx-target", "next .sibling")

  // Test Previous
  hx.target(extended_css_selector: hx.Previous(".sibling"))
  |> assert_attribute("hx-target", "previous .sibling")
}

pub fn swap_test() {
  // Without option
  hx.swap(swap: hx.InnerHTML)
  |> assert_attribute("hx-swap", "innerHTML")

  // With option - Transition
  hx.swap_with(swap: hx.OuterHTML, config: hx.Transition(True))
  |> assert_attribute("hx-swap", "outerHTML transition:true")

  // With option - Swap timing
  hx.swap_with(swap: hx.Afterend, config: hx.SwapTiming(duration.seconds(1)))
  |> assert_attribute("hx-swap", "afterend swap:1000ms")

  // With option - Scroll
  hx.swap_with(swap: hx.Beforeend, config: hx.ScrollTo(hx.TargetScroll(hx.Top)))
  |> assert_attribute("hx-swap", "beforeend scroll:top")

  // With option - Show
  hx.swap_with(swap: hx.Delete, config: hx.Show(hx.TargetShow(hx.Bottom)))
  |> assert_attribute("hx-swap", "delete show:bottom")
}

pub fn swap_oob_test() {
  // Basic swap oob
  hx.swap_oob(swap: hx.InnerHTML, css_selector: None)
  |> assert_attribute("hx-swap-oob", "innerHTML")

  // Swap oob with CSS selector
  hx.swap_oob(swap: hx.OuterHTML, css_selector: Some("#target"))
  |> assert_attribute("hx-swap-oob", "outerHTML:#target")

  // Swap oob with modifier
  hx.swap_oob_with(
    swap: hx.Afterend,
    css_selector: None,
    config: hx.Transition(True),
  )
  |> assert_attribute("hx-swap-oob", "afterend transition:true")

  // Swap oob with both CSS selector and modifier
  hx.swap_oob_with(
    swap: hx.Beforeend,
    css_selector: Some(".container"),
    config: hx.ScrollTo(hx.TargetScroll(hx.Top)),
  )
  |> assert_attribute("hx-swap-oob", "beforeend:.container scroll:top")
}

pub fn sync_test() {
  // Default strategy (no explicit strategy, uses drop behavior)
  hx.sync(hx.Default(hx.Closest("form")))
  |> assert_attribute("hx-sync", "closest form")

  // Explicit drop strategy
  hx.sync(hx.Drop(hx.Closest("form")))
  |> assert_attribute("hx-sync", "closest form:drop")

  // Abort strategy
  hx.sync(hx.Abort(hx.This))
  |> assert_attribute("hx-sync", "this:abort")

  // Replace strategy
  hx.sync(hx.Replace(hx.Selector("#form")))
  |> assert_attribute("hx-sync", "#form:replace")

  // Queue with First
  hx.sync(hx.Queue(hx.Selector("#form"), hx.First))
  |> assert_attribute("hx-sync", "#form:queue first")

  // Queue with Last
  hx.sync(hx.Queue(hx.Selector("#form"), hx.Last))
  |> assert_attribute("hx-sync", "#form:queue last")

  // Queue with All
  hx.sync(hx.Queue(hx.Selector("#form"), hx.All))
  |> assert_attribute("hx-sync", "#form:queue all")
}

pub fn select_test() {
  hx.select(".result-item")
  |> assert_attribute("hx-select", ".result-item")
}

pub fn select_oob_test() {
  // Single selector
  hx.select_oob([".result-item"])
  |> assert_attribute("hx-select-oob", ".result-item")

  // Multiple selectors
  hx.select_oob([".card", "#sidebar", ".footer"])
  |> assert_attribute("hx-select-oob", ".card,#sidebar,.footer")
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
  hx.disable_elt([hx.Selector(".form-input")])
  |> assert_attribute("hx-disable-elt", ".form-input")

  // Multiple selectors
  hx.disable_elt([
    hx.Selector(".btn"),
    hx.Closest(".form"),
    hx.This,
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
  hx.trigger([hx.click()])
  |> assert_attribute("hx-trigger", "click")

  hx.trigger([hx.change()])
  |> assert_attribute("hx-trigger", "change")

  hx.trigger([hx.submit()])
  |> assert_attribute("hx-trigger", "submit")

  hx.trigger([hx.load()])
  |> assert_attribute("hx-trigger", "load")

  hx.trigger([hx.input()])
  |> assert_attribute("hx-trigger", "input")

  hx.trigger([hx.focus()])
  |> assert_attribute("hx-trigger", "focus")

  hx.trigger([hx.blur()])
  |> assert_attribute("hx-trigger", "blur")

  hx.trigger([hx.keyup()])
  |> assert_attribute("hx-trigger", "keyup")

  hx.trigger([hx.keydown()])
  |> assert_attribute("hx-trigger", "keydown")

  hx.trigger([hx.mouseover()])
  |> assert_attribute("hx-trigger", "mouseover")

  hx.trigger([hx.mouseout()])
  |> assert_attribute("hx-trigger", "mouseout")

  hx.trigger([hx.scroll()])
  |> assert_attribute("hx-trigger", "scroll")

  hx.trigger([hx.resize()])
  |> assert_attribute("hx-trigger", "resize")

  hx.trigger([hx.dom_content_loaded()])
  |> assert_attribute("hx-trigger", "DOMContentLoaded")
}

pub fn htmx_events_test() {
  // Test HTMX-specific events
  hx.trigger([hx.htmx_before_request()])
  |> assert_attribute("hx-trigger", "htmx:beforeRequest")

  hx.trigger([hx.htmx_after_request()])
  |> assert_attribute("hx-trigger", "htmx:afterRequest")

  hx.trigger([hx.htmx_before_swap()])
  |> assert_attribute("hx-trigger", "htmx:beforeSwap")

  hx.trigger([hx.htmx_after_swap()])
  |> assert_attribute("hx-trigger", "htmx:afterSwap")

  hx.trigger([hx.htmx_before_settle()])
  |> assert_attribute("hx-trigger", "htmx:beforeSettle")

  hx.trigger([hx.htmx_after_settle()])
  |> assert_attribute("hx-trigger", "htmx:afterSettle")

  hx.trigger([hx.htmx_load()])
  |> assert_attribute("hx-trigger", "htmx:load")

  hx.trigger([hx.htmx_config_request()])
  |> assert_attribute("hx-trigger", "htmx:configRequest")

  hx.trigger([hx.htmx_response_error()])
  |> assert_attribute("hx-trigger", "htmx:responseError")

  hx.trigger([hx.htmx_send_error()])
  |> assert_attribute("hx-trigger", "htmx:sendError")

  hx.trigger([hx.htmx_timeout()])
  |> assert_attribute("hx-trigger", "htmx:timeout")

  hx.trigger([hx.htmx_validation_validate()])
  |> assert_attribute("hx-trigger", "htmx:validation:validate")

  hx.trigger([hx.htmx_validation_failed()])
  |> assert_attribute("hx-trigger", "htmx:validation:failed")

  hx.trigger([hx.htmx_validation_halted()])
  |> assert_attribute("hx-trigger", "htmx:validation:halted")

  hx.trigger([hx.htmx_xhr_abort()])
  |> assert_attribute("hx-trigger", "htmx:xhr:abort")

  hx.trigger([hx.htmx_xhr_loadend()])
  |> assert_attribute("hx-trigger", "htmx:xhr:loadend")

  hx.trigger([hx.htmx_xhr_loadstart()])
  |> assert_attribute("hx-trigger", "htmx:xhr:loadstart")

  hx.trigger([hx.htmx_xhr_progress()])
  |> assert_attribute("hx-trigger", "htmx:xhr:progress")
}

pub fn intersect_events_test() {
  // Basic intersect event
  hx.trigger([hx.intersect([])])
  |> assert_attribute("hx-trigger", "intersect")

  // Intersect event with once modifier
  hx.trigger([hx.intersect_once([])])
  |> assert_attribute("hx-trigger", "intersect once")

  // Intersect event with threshold
  hx.trigger([hx.intersect([hx.Threshold(0.5)])])
  |> assert_attribute("hx-trigger", "intersect threshold:0.5")

  // Intersect with root and threshold
  hx.trigger([hx.intersect([hx.Root("#container"), hx.Threshold(0.75)])])
  |> assert_attribute("hx-trigger", "intersect root:#container threshold:0.75")

  // Intersect once with threshold
  hx.trigger([hx.intersect_once([hx.Threshold(0.5)])])
  |> assert_attribute("hx-trigger", "intersect threshold:0.5 once")
}

pub fn custom_events_test() {
  // Test custom event creation
  hx.trigger([hx.custom("myCustomEvent")])
  |> assert_attribute("hx-trigger", "myCustomEvent")

  // Test multiple custom events
  hx.trigger([hx.custom("event1"), hx.custom("event2")])
  |> assert_attribute("hx-trigger", "event1, event2")
}

pub fn event_modifiers_test() {
  // Test with_delay modifier
  hx.trigger([hx.with_delay(hx.click(), duration.seconds(2))])
  |> assert_attribute("hx-trigger", "click delay:2000ms")

  // Test with_throttle modifier
  hx.trigger([
    hx.with_throttle(hx.input(), duration.milliseconds(300)),
  ])
  |> assert_attribute("hx-trigger", "input throttle:300ms")

  // Test with_once modifier
  hx.trigger([hx.with_once(hx.click())])
  |> assert_attribute("hx-trigger", "click once")

  // Test with_changed modifier
  hx.trigger([hx.with_changed(hx.input())])
  |> assert_attribute("hx-trigger", "input changed")

  // Test with_from modifier
  hx.trigger([hx.with_from(hx.click(), hx.Document)])
  |> assert_attribute("hx-trigger", "click from:document")

  // Test with_target modifier
  hx.trigger([hx.with_target(hx.click(), "#target")])
  |> assert_attribute("hx-trigger", "click target:#target")

  // Test with_consume modifier
  hx.trigger([hx.with_consume(hx.click())])
  |> assert_attribute("hx-trigger", "click consume")

  // Test with_queue modifier
  hx.trigger([hx.with_queue(hx.click(), Some(hx.First))])
  |> assert_attribute("hx-trigger", "click queue:first")
}

pub fn chained_event_modifiers_test() {
  // Test chaining multiple modifiers
  let complex_event =
    hx.click()
    |> hx.with_delay(duration.milliseconds(100))
    |> hx.with_once
    |> hx.with_from(hx.Window)

  hx.trigger([complex_event])
  |> assert_attribute("hx-trigger", "click from:window once delay:100ms")
}

pub fn multiple_mixed_events_test() {
  // Test combining different types of events
  hx.trigger([
    hx.click(),
    hx.with_delay(hx.keyup(), duration.seconds(1)),
    hx.htmx_after_request(),
    hx.intersect_once([]),
  ])
  |> assert_attribute(
    "hx-trigger",
    "click, keyup delay:1000ms, htmx:afterRequest, intersect once",
  )
}

pub fn new_htmx_events_test() {
  // Test newly added HTMX lifecycle events
  hx.trigger([hx.htmx_confirm()])
  |> assert_attribute("hx-trigger", "htmx:confirm")

  hx.trigger([hx.htmx_before_send()])
  |> assert_attribute("hx-trigger", "htmx:beforeSend")

  hx.trigger([hx.htmx_validate_url()])
  |> assert_attribute("hx-trigger", "htmx:validateUrl")

  hx.trigger([hx.htmx_before_on_load()])
  |> assert_attribute("hx-trigger", "htmx:beforeOnLoad")

  hx.trigger([hx.htmx_after_on_load()])
  |> assert_attribute("hx-trigger", "htmx:afterOnLoad")

  hx.trigger([hx.htmx_send_abort()])
  |> assert_attribute("hx-trigger", "htmx:sendAbort")

  hx.trigger([hx.htmx_abort()])
  |> assert_attribute("hx-trigger", "htmx:abort")
}

pub fn htmx_node_processing_events_test() {
  // Test node processing events
  hx.trigger([hx.htmx_before_process_node()])
  |> assert_attribute("hx-trigger", "htmx:beforeProcessNode")

  hx.trigger([hx.htmx_after_process_node()])
  |> assert_attribute("hx-trigger", "htmx:afterProcessNode")

  hx.trigger([hx.htmx_before_cleanup_element()])
  |> assert_attribute("hx-trigger", "htmx:beforeCleanupElement")

  hx.trigger([hx.htmx_before_transition()])
  |> assert_attribute("hx-trigger", "htmx:beforeTransition")

  hx.trigger([hx.htmx_trigger()])
  |> assert_attribute("hx-trigger", "htmx:trigger")
}

pub fn htmx_oob_events_test() {
  // Test out-of-band events
  hx.trigger([hx.htmx_oob_before_swap()])
  |> assert_attribute("hx-trigger", "htmx:oobBeforeSwap")

  hx.trigger([hx.htmx_oob_after_swap()])
  |> assert_attribute("hx-trigger", "htmx:oobAfterSwap")

  hx.trigger([hx.htmx_oob_error_no_target()])
  |> assert_attribute("hx-trigger", "htmx:oobErrorNoTarget")
}

pub fn htmx_error_events_test() {
  // Test error and history events
  hx.trigger([hx.htmx_swap_error()])
  |> assert_attribute("hx-trigger", "htmx:swapError")

  hx.trigger([hx.htmx_error()])
  |> assert_attribute("hx-trigger", "htmx:error")

  hx.trigger([hx.htmx_history_item_created()])
  |> assert_attribute("hx-trigger", "htmx:historyItemCreated")

  hx.trigger([hx.htmx_history_cache_error()])
  |> assert_attribute("hx-trigger", "htmx:historyCacheError")

  hx.trigger([hx.htmx_event_filter_error()])
  |> assert_attribute("hx-trigger", "htmx:eventFilter:error")

  hx.trigger([hx.htmx_syntax_error()])
  |> assert_attribute("hx-trigger", "htmx:syntax:error")

  // History events
  hx.trigger([hx.htmx_before_history_save()])
  |> assert_attribute("hx-trigger", "htmx:beforeHistorySave")

  hx.trigger([hx.htmx_before_history_update()])
  |> assert_attribute("hx-trigger", "htmx:beforeHistoryUpdate")

  hx.trigger([hx.htmx_history_restore()])
  |> assert_attribute("hx-trigger", "htmx:historyRestore")

  hx.trigger([hx.htmx_pushed_into_history()])
  |> assert_attribute("hx-trigger", "htmx:pushedIntoHistory")

  hx.trigger([hx.htmx_replaced_in_history()])
  |> assert_attribute("hx-trigger", "htmx:replacedInHistory")

  hx.trigger([hx.htmx_restored()])
  |> assert_attribute("hx-trigger", "htmx:restored")

  // Cache events
  hx.trigger([hx.htmx_history_cache_hit()])
  |> assert_attribute("hx-trigger", "htmx:historyCacheHit")

  hx.trigger([hx.htmx_history_cache_miss()])
  |> assert_attribute("hx-trigger", "htmx:historyCacheMiss")

  hx.trigger([hx.htmx_history_cache_miss_load()])
  |> assert_attribute("hx-trigger", "htmx:historyCacheMissLoad")

  hx.trigger([hx.htmx_history_cache_miss_load_error()])
  |> assert_attribute("hx-trigger", "htmx:historyCacheMissLoadError")

  // Error events
  hx.trigger([hx.htmx_bad_response_url()])
  |> assert_attribute("hx-trigger", "htmx:badResponseUrl")

  hx.trigger([hx.htmx_invalid_path()])
  |> assert_attribute("hx-trigger", "htmx:invalidPath")

  hx.trigger([hx.htmx_on_load_error()])
  |> assert_attribute("hx-trigger", "htmx:onLoadError")

  hx.trigger([hx.htmx_target_error()])
  |> assert_attribute("hx-trigger", "htmx:targetError")

  hx.trigger([hx.htmx_eval_disallowed_error()])
  |> assert_attribute("hx-trigger", "htmx:evalDisallowedError")

  // UI events
  hx.trigger([hx.htmx_prompt()])
  |> assert_attribute("hx-trigger", "htmx:prompt")

  hx.trigger([hx.htmx_session_storage_test()])
  |> assert_attribute("hx-trigger", "htmx:sessionStorageTest")
}

pub fn revealed_event_test() {
  // Test revealed event
  hx.trigger([hx.revealed()])
  |> assert_attribute("hx-trigger", "revealed")

  // Test revealed with modifiers
  hx.trigger([hx.with_once(hx.revealed())])
  |> assert_attribute("hx-trigger", "revealed once")
}

pub fn on_attribute_test() {
  // Test hx-on attribute for inline event handlers
  hx.on("click", "alert('Clicked!')")
  |> assert_attribute("hx-on:click", "alert('Clicked!')")

  hx.on("htmx:afterSwap", "console.log('Swapped')")
  |> assert_attribute("hx-on:htmx:afterSwap", "console.log('Swapped')")
}

pub fn enhanced_swap_modifiers_test() {
  // Test enhanced scroll modifiers

  // Target scroll
  hx.swap_with(swap: hx.InnerHTML, config: hx.ScrollTo(hx.TargetScroll(hx.Top)))
  |> assert_attribute("hx-swap", "innerHTML scroll:top")

  // Element scroll with selector
  hx.swap_with(
    swap: hx.InnerHTML,
    config: hx.ScrollTo(hx.ElementScroll("#main", hx.Bottom)),
  )
  |> assert_attribute("hx-swap", "innerHTML scroll:#main:bottom")

  // Window scroll
  hx.swap_with(swap: hx.InnerHTML, config: hx.ScrollTo(hx.WindowScroll(hx.Top)))
  |> assert_attribute("hx-swap", "innerHTML scroll:window:top")

  // Test enhanced show modifiers

  // Target show
  hx.swap_with(swap: hx.OuterHTML, config: hx.Show(hx.TargetShow(hx.Bottom)))
  |> assert_attribute("hx-swap", "outerHTML show:bottom")

  // Element show with selector
  hx.swap_with(
    swap: hx.OuterHTML,
    config: hx.Show(hx.ElementShow(".result", hx.Top)),
  )
  |> assert_attribute("hx-swap", "outerHTML show:.result:top")

  // Window show
  hx.swap_with(swap: hx.OuterHTML, config: hx.Show(hx.WindowShow(hx.Bottom)))
  |> assert_attribute("hx-swap", "outerHTML show:window:bottom")
}

pub fn queue_modifier_fix_test() {
  // Test that queue modifier has no extra space
  hx.trigger([hx.with_queue(hx.click(), None)])
  |> assert_attribute("hx-trigger", "click queue:none")
}
