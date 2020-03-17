defmodule Acceptance.Ast.InlineCodeTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  describe "Inline Code" do
    test "plain simple" do
      markdown = "`foo`\n"
      html = "<p><code class=\"inline\">foo</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "plain simple, right?" do
      markdown = "`hi`lo`\n"
      html = "<p><code class=\"inline\">hi</code>lo`</p>\n"
      ast      = parse_html(html)
      messages = [{:warning, 1, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "this time you got it right" do
      markdown = "`a\nb`c\n"
      html = "<p><code class=\"inline\">a b</code>c</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "and again!!!" do
      markdown = "+ ``a `\n`\n b``c"
      html = "<ul>\n<li><code class=\"inline\">a ` ` b</code>c</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "Inline Code with escapes" do
    test "a lone escaped backslash" do
      markdown = "`\\\\`"
      html = "<p><code class=\"inline\">\\\\</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "with company" do
      markdown = "`hello \\\\ world`"
      html = "<p><code class=\"inline\">hello \\\\ world</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "unescaped escape" do
      markdown = "`\\`"
      html = "<p><code class=\"inline\">\\</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  
    test "backtix cannot be escaped" do 
      markdown = "`` \\` ``"
      html = "<p><code class=\"inline\">\\`</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "unless at the beginning" do 
      markdown = "\\``code\\`"
      html = "<p>`<code class=\"inline\">code\\</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "whitespace treatment" do
    test "squashing" do
      markdown = "`alpha   beta`"
      html = "<p><code class=\"inline\">alpha beta</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "remove at start" do
      markdown = "`  alpha beta`"
      html = "<p><code class=\"inline\">alpha beta</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "remove and squash" do
      markdown = "`  alpha   beta `"
      html = "<p><code class=\"inline\">alpha beta</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "remove and squash newlines too" do
      markdown = "`\n  alpha  \n\n beta `"
      html = "<p><code class=\"inline\">alpha beta</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "inline code inside lists (was regtest #48)" do 
      markdown = " * `a\n * b`"
      html     = ~s[<ul>\n<li><code class="inline">a * b</code>\n</li>\n</ul>\n]
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
