defmodule Acceptance.InlineCodeTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1]

  describe "Inline Code" do
    test "plain simple" do
      markdown = "`foo`\n"
      html = "<p><code class=\"inline\">foo</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "plain simple, right?" do
      markdown = "`hi`lo`\n"
      html = "<p><code class=\"inline\">hi</code>lo`</p>\n"
      messages = [{:warning, 1, "Closing unclosed backquotes ` at end of input"}]

      assert as_html(markdown) == {:error, html, messages}
    end

    test "this time you got it right" do
      markdown = "`a\nb`c\n"
      html = "<p><code class=\"inline\">a b</code>c</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "and again!!!" do
      markdown = "+ ``a `\n`\n b``c"
      html = "<ul>\n<li><code class=\"inline\">a ` ` b</code>c\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Inline Code with escapes" do
    test "a lone escaped backslash" do
      markdown = "`\\\\`"
      html = "<p><code class=\"inline\">\\\\</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "with company" do
      markdown = "`hello \\\\ world`"
      html = "<p><code class=\"inline\">hello \\\\ world</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "unescaped escape" do
      markdown = "`\\`"
      html = "<p><code class=\"inline\">\\</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  
    test "backtix cannot be escaped" do 
      markdown = "`` \\` ``"
      html = "<p><code class=\"inline\">\\`</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "unless at the beginning" do 
      markdown = "\\``code\\`"
      html = "<p>`<code class=\"inline\">code\\</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "whitespace treatment" do
    test "squashing" do
      markdown = "`alpha   beta`"
      html = "<p><code class=\"inline\">alpha beta</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "remove at start" do
      markdown = "`  alpha beta`"
      html = "<p><code class=\"inline\">alpha beta</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "remove and squash" do
      markdown = "`  alpha   beta `"
      html = "<p><code class=\"inline\">alpha beta</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "remove and squash newlines too" do
      markdown = "`\n  alpha  \n\n beta `"
      html = "<p><code class=\"inline\">alpha beta</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
