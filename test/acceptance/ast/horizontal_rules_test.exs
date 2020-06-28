defmodule Acceptance.Ast.HorizontalRulesTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import EarmarkAstDsl
  
  describe "Horizontal rules" do

    test "thick, thin & medium" do
      markdown = "***\n---\n___\n"
      html     = "<hr class=\"thick\"/>\n<hr class=\"thin\"/>\n<hr class=\"medium\"/>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "not a rule" do
      markdown = "+++\n"
      html     = "<p>+++</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "not in code" do
      markdown = "    ***\n    \n     a"
      html     = "<pre><code>***\n\n a</code></pre>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "not in code, second line" do
      markdown = "Foo\n    ***\n"
      html     = "<p>Foo</p>\n<pre><code>***</code></pre>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "medium, long" do
      markdown = "_____________________________________\n"
      html     = "<hr class=\"medium\"/>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "emmed, so to speak" do
      markdown = " *-*\n"
      ast      = p([" ", tag("em", "-")])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "in lists" do
      markdown = "- foo\n***\n- bar\n"
      html     = "<ul>\n<li>foo</li>\n</ul>\n<hr class=\"thick\"/>\n<ul>\n<li>bar</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "setext rules over rules (why am I soo witty?)" do
      markdown = "Foo\n---\nbar\n"
      html     = "<h2>Foo</h2>\n<p>bar</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "in lists, thick this time (why am I soo good to you?)" do
      markdown = "* Foo\n* * *\n* Bar\n"
      html = "<ul>\n<li>Foo</li>\n</ul>\n<hr class=\"thick\"/>\n<ul>\n<li>Bar</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "Horizontal Rules and IAL" do 
    test "add a class and an id" do
      markdown = "***\n{: .custom}\n---\n{: .klass #id42}\n___\n{: hello=world}\n"
      html     = "<hr class=\"custom thick\" />\n<hr class=\"klass thin\" id=\"id42\" />\n<hr class=\"medium\" hello=\"world\" />\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}

    end
  end
end

# SPDX-License-Identifier: Apache-2.0
