defmodule Acceptance.Html1.EmptyTest do
  use ExUnit.Case, async: true
  import Support.Html1Helpers
  
  @moduletag :html1

  test "empty" do
    markdown = ""
    html     = ""
    messages = []

    assert to_html1(markdown) == {:ok, html, messages}
  end

  test "almost empty" do
    markdown = "  "
    html     = ""
    messages = []

    assert to_html1(markdown) == {:ok, html, messages}
  end
  
end
