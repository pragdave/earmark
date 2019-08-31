defmodule Acceptance.Html.EmptyTest do
  use ExUnit.Case, async: true

  test "empty" do
    markdown = ""
    html     = ""
    messages = []

    assert Earmark.as_html(markdown) == {:ok, html, messages}
  end

  test "almost empty" do
    markdown = "  "
    html     = ""
    messages = []

    assert Earmark.as_html(markdown) == {:ok, html, messages}
  end
  
end
