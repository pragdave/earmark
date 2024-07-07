defmodule Test.Acceptance.Html.InnerHtmlTest do
  use Support.AcceptanceTestCase

  describe "output with the inner_html option" do
    test "one para" do
      markdown = "aaa"
      html = "aaa\n"
      messages = []

      assert as_html(markdown, inner_html: true) == {:ok, html, messages}
    end

    test "two paras" do
      markdown = "aaa\n\nbbb\n"
      html = "aaa\nbbb\n"
      messages = []

      assert as_html(markdown, inner_html: true) == {:ok, html, messages}
    end

    test "a list and a para" do
      markdown = "1. item\n\npara"
      html = "<ol>\n  <li>\nitem  </li>\n</ol>\npara\n"
      messages = []

      assert as_html(markdown, inner_html: true) == {:ok, html, messages}
    end

    test "complex content of the para" do
      markdown = "a **b** `c`"
      html = "a \n<strong>b</strong> \n<code class=\"inline\">c</code>"
      messages = []

      assert as_html(markdown, inner_html: true) == {:ok, html, messages}
    end
  end
end
