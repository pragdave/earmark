defmodule Acceptance.Html.RenderSpecific.SmartyPantsTest do
  use Support.AcceptanceTestCase

  describe "smarty pants on" do
    test "paired double" do
      markdown = "a \"double\" quote"
      html     = "<p>\na “double” quote</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "unpaired double" do
      markdown = "a \"double\" \"quote"
      html     = "<p>\na “double” “quote</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "two doubles" do
      markdown = "a \"double\" \"quote\""
      html     = "<p>\na “double” “quote”</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "paired single" do
      markdown = "a 'single' quote"
      html     = "<p>\na ‘single’ quote</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "unpaired single" do
      markdown = "a 'single' 'quote"
      html     = "<p>\na ‘single’ ‘quote</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "two singles" do
      markdown = "a 'single' 'quote'"
      html     = "<p>\na ‘single’ ‘quote’</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "a mess" do
      markdown = ~s{"a" 'messy' "affair"}
      html     = "<p>\n“a” ‘messy’ “affair”</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "en dash" do
      markdown = "1947 -- 2020"
      html     = "<p>\n1947 – 2020</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "em dash" do
      markdown = "Earmark---A Pure Elixir Markdown Processor"
      html     = "<p>\nEarmark—A Pure Elixir Markdown Processor</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end
