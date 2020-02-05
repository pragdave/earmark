defmodule Acceptance.Ast.BlockQuotesTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]

  @moduletag :ast

  describe "with breaks: true" do
    test "acceptance test 490 with breaks" do
      markdown = "> bar\nbaz\n> foo\n"
      html = "<blockquote><p>bar<br />baz<br />foo</p>\n</blockquote>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 580 with breaks" do
      html     = "<ol>\n<li>foo<br />bar</li>\n</ol>\n"
      markdown = "1. foo\nbar"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 581 with breaks" do
      html     = "<ul>\n<li>a<br />b<br />c</li>\n</ul>\n"
      markdown = "* a\n  b\nc"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 582 with breaks" do
      html     = "<ul>\n<li>x<br />a<br />| A | B |</li>\n</ul>\n"
      markdown = "* x\n  a\n| A | B |"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 583 with breaks" do
      html     = "<ul>\n<li>x<br />| A | B |</li>\n</ul>\n"
      markdown = "* x\n | A | B |"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 630 with breaks" do
      html     = "<p>*not emphasized*<br />[not a link](/foo)<br />`not code`<br />1. not a list<br />* not a list<br /># not a header<br />[foo]: /url \"not a reference\"</p>\n"
      markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code\\`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "more" do
      html = "<blockquote><h1>Foo</h1>\n<p>bar<br />baz</p>\n</blockquote>\n"
      markdown = "> # Foo\n> bar\n> baz\n"
      ast      = parse_html(html)
      messages = []


      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end
  end

  describe "Block Quotes" do
    test "quote my block" do
      markdown = "> Foo"
      html     = "<blockquote><p>Foo</p>\n</blockquote>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "and block my quotes" do
      markdown = "> # Foo\n> bar\n> baz\n"
      html     = "<blockquote><h1>Foo</h1>\n<p>bar\nbaz</p>\n</blockquote>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "linient we are" do
      markdown = "> bar\nbaz\n> foo\n"
      html     = "<blockquote><p>bar\nbaz\nfoo</p>\n</blockquote>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "lists in blockquotes? Coming up Sir" do
      markdown = "> - foo\n- bar\n"
      html     = "<blockquote><ul>\n<li>foo</li>\n</ul>\n</blockquote>\n<ul>\n<li>bar</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "indented case" do
      markdown = " > - foo\n- bar\n"
      html     = "<blockquote><ul>\n<li>foo</li>\n</ul>\n</blockquote>\n<ul>\n<li>bar</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "Nested blockquotes" do
    test "just two blocks" do
      markdown = ">>foo\n> bar\n"
      html     = "<blockquote>\n<blockquote>\n<p>foo\nbar</p></blockquote></blockquote>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "attached list" do 
      markdown = " >- foo\n- bar\n"
      html     = "<blockquote><ul>\n<li>foo</li>\n</ul>\n</blockquote>\n<ul>\n<li>bar</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
