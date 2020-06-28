defmodule Acceptance.Ast.BlockQuotesTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2]
  import EarmarkAstDsl

  @moduletag :ast

  describe "with breaks: true" do
    test "acceptance test 490 with breaks" do
      markdown = "> bar\nbaz\n> foo\n"
      ast      = bq(p(brlist(~w[bar baz foo])))
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 580 with breaks" do
      markdown = "1. foo\nbar"
      ast      = tag("ol", [tag("li", brlist(~w[foo bar]))])
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 581 with breaks" do
      markdown = "* a\n  b\nc"
      ast      = tag("ul", tag("li", brlist(~w[a b c])))
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 582 with breaks" do
      markdown = "* x\n  a\n| A | B |"
      ast      = tag("ul", tag("li", brlist(["x", "a", "| A | B |"])))
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 583 with breaks" do
      markdown = "* x\n | A | B |"
      ast      = tag("ul", tag("li", brlist(["x", "| A | B |"])))
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "acceptance test 630 with breaks" do
      markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code\\`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
      ast      = p(brlist([
        "*not emphasized*",
        "[not a link](/foo)",
        "`not code`",
        "1. not a list",
        "* not a list",
        "# not a header",
        "[foo]: /url \"not a reference\""]))
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end

    test "more" do
      markdown = "> # Foo\n> bar\n> baz\n"
      ast      = bq([tag("h1", "Foo"), p(brlist(~w[bar baz]))])
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, [ast], messages}
    end
  end

  describe "Block Quotes" do
    test "quote my block" do
      markdown = "> Foo"
      ast      = bq(p("Foo"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "and block my quotes" do
      markdown = "> # Foo\n> bar\n> baz\n"
      ast      = bq([tag("h1", "Foo"), p("bar\nbaz")])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "linient we are" do
      markdown = "> bar\nbaz\n> foo\n"
      ast      = bq(p("bar\nbaz\nfoo"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "lists in blockquotes? Coming up Sir" do
      markdown = "> - foo\n- bar\n"
      ast      = [bq(tag("ul", tag("li", "foo"))), tag("ul", tag("li", "bar"))]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "indented case" do
      markdown = " > - foo\n- bar\n"
      ast      = [bq(tag("ul", tag("li", "foo"))), tag("ul", tag("li", "bar"))]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "Nested blockquotes" do
    test "just two blocks" do
      markdown = ">>foo\n> bar\n"
      ast      = bq(bq(p("foo\nbar")))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "attached list" do 
      markdown = " >- foo\n- bar\n"
      ast      = [bq(tag("ul", tag("li", "foo"))), tag("ul", tag("li", "bar"))]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end


  defp bq(content, atts \\ []) do
    tag("blockquote", content, atts)
  end

  defp br, do: void_tag("br")

  defp brlist(elements) do
    elements
    |> Enum.intersperse(br())
  end
end

# SPDX-License-Identifier: Apache-2.0
