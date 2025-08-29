/// Extended CSS selector with special HTMX keywords
pub type Selector {
  CssSelector(css_selector: String)
  Document
  Window
  Closest(selector: String)
  Find(selector: String)
  Next(selector: String)
  Previous(selector: String)
  This
}

pub fn to_string(extended_css_selector: Selector) -> String {
  case extended_css_selector {
    CssSelector(css_selector) -> css_selector
    Document -> "document"
    Window -> "window"
    Closest(css_selector) -> "closest " <> css_selector
    Find(css_selector) -> "find " <> css_selector
    Next(css_selector) -> "next " <> css_selector
    Previous(css_selector) -> "previous " <> css_selector
    This -> "this"
  }
}
