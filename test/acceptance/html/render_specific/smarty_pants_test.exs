defmodule Acceptance.Html.RenderSpecific.SmartyPantsTest do
  use Support.AcceptanceTestCase

  describe "smarty pants on" do
    test "paired double" do
      markdown = "a \"double\" quote"
      html = "<p>\na “double” quote</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "unpaired double" do
      markdown = "a \"double\" \"quote"
      html = "<p>\na “double” “quote</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "ignores inline code" do
      markdown = "`IO.puts \"no curly quotes\"`"
      html = "<p>\n<code class=\"inline\">IO.puts &quot;no curly quotes&quot;</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "ignores pre code blocks" do
      markdown = "```\nIO.puts \"no curly quotes\"\n```"
      html = "<pre><code>IO.puts &quot;no curly quotes&quot;</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "two doubles" do
      markdown = "a \"double\" \"quote\""
      html = "<p>\na “double” “quote”</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "paired single" do
      markdown = "a 'single' quote"
      html = "<p>\na ‘single’ quote</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "unpaired single" do
      markdown = "a 'single' 'quote"
      html = "<p>\na ‘single’ ‘quote</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "two singles" do
      markdown = "a 'single' 'quote'"
      html = "<p>\na ‘single’ ‘quote’</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "a mess" do
      markdown = ~s{"a" 'messy' "affair"}
      html = "<p>\n“a” ‘messy’ “affair”</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "en dash" do
      markdown = "1947 -- 2020"
      html = "<p>\n1947 – 2020</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "em dash" do
      markdown = "Earmark---A Pure Elixir Markdown Processor"
      html = "<p>\nEarmark—A Pure Elixir Markdown Processor</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end
