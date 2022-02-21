defmodule Acceptance.Html.EmptyTest do
  use Support.AcceptanceTestCase

  test "empty" do
    markdown = ""
    html     = ""
    messages = []

    assert as_html(markdown) == {:ok, html, messages}
  end

  test "almost empty" do
    markdown = "  "
    html     = ""
    messages = []

    assert as_html(markdown) == {:ok, html, messages}
  end

end
