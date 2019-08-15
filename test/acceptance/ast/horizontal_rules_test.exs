defmodule Acceptance.Ast.HorizontalRulesTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, as_html: 1]

  describe "Horizontal rules" do

    @tag :ast
    test "thick, thin & medium" do
      markdown = "***\n---\n___\n"
      html     = "<hr class=\"thick\"/>\n<hr class=\"thin\"/>\n<hr class=\"medium\"/>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "not a rule" do
      markdown = "+++\n"
      html     = "<p>+++</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "not in code" do
      markdown = "    ***\n    \n     a"
      html     = "<pre><code>***\n\n a</code></pre>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "not in code, second line" do
      markdown = "Foo\n    ***\n"
      html     = "<p>Foo</p>\n<pre><code>***</code></pre>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "medium, long" do
      markdown = "_____________________________________\n"
      html     = "<hr class=\"medium\"/>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "emmed, so to speak" do
      markdown = " *-*\n"
      ast      = [{"p", [], [" ", {"em", [], ["-"]}]}] |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "in lists" do
      markdown = "- foo\n***\n- bar\n"
      html     = "<ul>\n<li>foo</li>\n</ul>\n<hr class=\"thick\"/>\n<ul>\n<li>bar</li>\n</ul>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "setext rules over rules (why am I soo witty?)" do
      markdown = "Foo\n---\nbar\n"
      html     = "<h2>Foo</h2>\n<p>bar</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "in lists, thick this time (why am I soo good to you?)" do
      markdown = "* Foo\n* * *\n* Bar\n"
      html = "<ul>\n<li>Foo</li>\n</ul>\n<hr class=\"thick\"/>\n<ul>\n<li>Bar</li>\n</ul>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []
      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
