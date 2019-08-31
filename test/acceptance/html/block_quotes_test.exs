defmodule Acceptance.Html.BlockQuotesTest do
  use ExUnit.Case, async: true

  describe "with breaks: true" do
    test "acceptance test 490 with breaks" do
      expected = "<blockquote><p>bar<br />baz<br />foo</p>\n</blockquote>\n"
      markdown = "> bar\nbaz\n> foo\n"
      assert Earmark.as_html!(markdown, breaks: true) == expected
    end

    test "acceptance test 580 with breaks" do
      expected = "<ol>\n<li>foo<br />bar\n</li>\n</ol>\n"
      markdown = "1. foo\nbar"
      assert Earmark.as_html!(markdown, breaks: true) == expected
    end

    test "acceptance test 581 with breaks" do
      expected = "<ul>\n<li>a<br />b<br />c\n</li>\n</ul>\n"
      markdown = "* a\n  b\nc"
      assert Earmark.as_html!(markdown, breaks: true) == expected
    end

    test "acceptance test 582 with breaks" do
      expected = "<ul>\n<li>x<br />a<br />| A | B |\n</li>\n</ul>\n"
      markdown = "* x\n  a\n| A | B |"
      assert Earmark.as_html!(markdown, breaks: true) == expected
    end

    test "acceptance test 583 with breaks" do
      expected = "<ul>\n<li>x<br />| A | B |\n</li>\n</ul>\n"
      markdown = "* x\n | A | B |"
      assert Earmark.as_html!(markdown, breaks: true) == expected
    end

    test "acceptance test 630 with breaks" do
      expected = "<p>*not emphasized*<br />[not a link](/foo)<br />`not code`<br />1. not a list<br />* not a list<br /># not a header<br />[foo]: /url “not a reference”</p>\n"
      markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code\\`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
      assert Earmark.as_html!(markdown, breaks: true) == expected
    end

    test "more" do
      html = "<blockquote><h1>Foo</h1>\n<p>bar<br />baz</p>\n</blockquote>\n"
      markdown = "> # Foo\n> bar\n> baz\n"
      messages = []

      assert Earmark.as_html(markdown, breaks: true) == {:ok, html, messages}
    end
  end

  describe "with breaks: false" do
    test "quote my block" do
      markdown = "> Foo"
      html     = "<blockquote><p>Foo</p>\n</blockquote>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end


    test "and block my quotes" do
      markdown = "> # Foo\n> bar\n> baz\n"
      html     = "<blockquote><h1>Foo</h1>\n<p>bar\nbaz</p>\n</blockquote>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "linient we are" do
      markdown = "> bar\nbaz\n> foo\n"
      html     = "<blockquote><p>bar\nbaz\nfoo</p>\n</blockquote>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "lists in blockquotes? Coming up Sir" do
      markdown = "> - foo\n- bar\n"
      html     = "<blockquote><ul>\n<li>foo\n</li>\n</ul>\n</blockquote>\n<ul>\n<li>bar\n</li>\n</ul>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
