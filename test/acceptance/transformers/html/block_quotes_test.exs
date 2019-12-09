defmodule Acceptance.Transformers.Html.BlockQuotesTest do
  use ExUnit.Case, async: true
  import Support.Html1Helpers
  
  @moduletag :html1

  describe "with breaks: true" do
    test "acceptance test 490 with breaks" do
      html = construct([
        :blockquote,
        :p,
        "bar",
        :br,
        "baz",
        :br,
        "foo" ])

      markdown = "> bar\nbaz\n> foo\n"
      assert to_html1(markdown, breaks: true) == {:ok, html, []}
    end

    test "acceptance test 580 with breaks" do
      html = construct([
        :ol,
        :li,
        "foo",
        :br,
        "bar" ])
      markdown = "1. foo\nbar"
      assert to_html1(markdown, breaks: true) == {:ok, html, []}
    end

    test "acceptance test 581 with breaks" do
      html = construct([
        :ul,
        :li,
        "a",
        :br,
        "b",
        :br,
        "c" ])
      markdown = "* a\n  b\nc"
      assert to_html1(markdown, breaks: true) == {:ok, html, []}
    end

    test "acceptance test 582 with breaks" do
      html = construct([
        :ul,
        :li,
        "x",
        :br,
        "a",
        :br,
        "| A | B |" ])
      markdown = "* x\n  a\n| A | B |"
      assert to_html1(markdown, breaks: true) == {:ok, html, []}
    end

    test "acceptance test 583 with breaks" do
      html = construct([
        :ul,
        :li,
        "x",
        :br,
        "| A | B |" ])
      markdown = "* x\n | A | B |"
      assert to_html1(markdown, breaks: true) == {:ok, html, []}
    end

    test "acceptance test 630 with breaks" do
      html = para([
        "*not emphasized*", :br, "[not a link](/foo)", :br, "`not code`",
        :br, "1. not a list", :br, "* not a list", :br, "# not a header",
        :br, "[foo]: /url &quot;not a reference&quot;" ])
      markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code\\`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
      assert to_html1(markdown, breaks: true) == {:ok, html, []}
    end

    test "more" do
      html = construct([
        :blockquote,
        :h1,
        "Foo",
        :POP,
        :p,
        "bar",
        :br,
        "baz" ])
      markdown = "> # Foo\n> bar\n> baz\n"
      messages = []

      assert to_html1(markdown, breaks: true) == {:ok, html, messages}
    end
  end

  describe "with breaks: false" do
    test "quote my block" do
      markdown = "> Foo"
      html     = construct([
        :blockquote,
        :p,
        "Foo"])

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end


    test "and block my quotes" do
      markdown = "> # Foo\n> bar\n> baz\n"
      html     = construct([
        :blockquote,
        :h1,
        "Foo",
        :POP,
        :p,
        "bar\nbaz" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "linient we are" do
      markdown = "> bar\nbaz\n> foo\n"
      html     = construct([
        :blockquote,
        :p,
        "bar\nbaz\nfoo" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "lists in blockquotes? Coming up Sir" do
      markdown = "> - foo\n- bar\n"
      html     = construct([
        :blockquote,
        :ul,
        :li,
        "foo",
        :POP,
        :POP,
        :POP,
        :ul,
        :li,
        "bar" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "indented case" do
      markdown = " > - foo\n- bar\n"
      html     = construct([
        :blockquote,
        :ul,
        :li,
        "foo",
        :POP,
        :POP,
        :POP,
        :ul,
        :li,
        "bar" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
