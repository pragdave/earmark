defmodule Acceptance.Ast.SetextHeadersTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  describe "Base cases" do

    test "Level one" do 
      markdown = "foo\n==="
      html     = "<h1>foo</h1>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Level two" do 
      markdown = "foo\n---"
      html     = "<h2>foo</h2>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "narrow escape" do
      markdown = "Foo\\\n----\n"
      html = "<h2>Foo\\</h2>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end

  describe "Combinations" do

    test "levels one and two" do
      markdown = "Foo *bar*\n=========\n\nFoo *bar*\n---------\n"
      html     = "<h1>Foo <em>bar</em></h1>\n<h2>Foo <em>bar</em></h2>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "and levels two and one" do
      markdown = "Foo\n-------------------------\n\nFoo\n=\n"
      html     = "<h2>Foo</h2>\n<h1>Foo</h1>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

  end
  # There is no consensus on this one, I prefer to not define the behavior of this unless
  # there is a real use case
  # c.f. http://johnmacfarlane.net/babelmark2/?text=%60Foo%0A----%0A%60%0A%0A%3Ca+title%3D%22a+lot%0A---%0Aof+dashes%22%2F%3E%0A
  #    html = "<h2>`Foo</h2>\n<p>`</p>\n<h2>&lt;a title=&quot;a lot</h2>\n<p>of dashes&quot;/&gt;</p>\n"
  #    markdown = "`Foo\n----\n`\n\n<a title=\"a lot\n---\nof dashes\"/>\n"
  #
  describe "Setext headers with some context" do 

    test "h1 after an unordered list" do 
      markdown = "* foo\n\nbar\n==="
      html     = "<ul><li>foo</li></ul><h1>bar</h1>"
      ast      = parse_html(html)
      messages = []
      
      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "h2 after an unordered list" do 
      markdown = "* foo\n\nbar\n---"
      html     = "<ul><li>foo</li></ul><h2>bar</h2>"
      ast      = parse_html(html)
      messages = []
      
      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "h1 after an ordered list and pending text" do 
      markdown = "1. foo\n\nbar\n===\ntext"
      html     = "<ol><li>foo</li></ol><h1>bar</h1><p>text</p>"
      ast      = parse_html(html)
      messages = []
      
      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "h2 between two lists" do 
      markdown = "* foo\n\nbar\n---\n\n1. baz"
      html     = "<ul><li>foo</li></ul><h2>bar</h2><ol><li>baz</li></ol>"
      ast      = parse_html(html)
      messages = []
      
      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "h2 between two lists more blank lines" do
      markdown = "1. foo\n\n\nbar\n---\n\n\n* baz"
      html     = "<ol><li>foo</li></ol><h2>bar</h2><ul><li>baz</li></ul>"
      ast      = parse_html(html)
      messages = []
      
      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "after a table" do 
    
    test "h2 after a table" do
      markdown = "|a|b|\n|d|e|\nbar\n---"
      html     = "<table><tbody><tr>\n<td style=\"text-align: left;\">a</td><td style=\"text-align: left;\">b</td>\n</tr>\n<tr>\n<td style=\"text-align: left;\">d</td><td style=\"text-align: left;\">e</td>\n</tr>\n</tbody>\n</table>\n<h2>bar</h2>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
