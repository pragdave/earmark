defmodule Acceptance.Html.BlockQuotesTest do
  use ExUnit.Case, async: true

  describe "with breaks: true" do
    test "acceptance test 490 with breaks" do
      markdown = "> bar\nbaz\n> foo\n"
      html     = "<blockquote>\n  <p>\nbar    <br />\nbaz    <br />\nfoo  </p>\n</blockquote>\n"
      assert Earmark.as_html!(markdown, breaks: true) == html
    end

    test "acceptance test 582 with breaks" do
      markdown = "* x\n  a\n| A | B |"
      html     = "<ul>\n  <li>\nx    <br />\na    <br />\n| A | B |  </li>\n</ul>\n"
      assert Earmark.as_html!(markdown, breaks: true) == html
    end
  end

  describe "with breaks: false" do
    test "quote my block" do
      markdown = "> Foo"
      html     = "<blockquote>\n  <p>\nFoo  </p>\n</blockquote>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "lists in blockquotes? Coming up Sir" do
      markdown = "> - foo\n- bar\n"
      html     = "<blockquote>\n  <ul>\n    <li>\nfoo    </li>\n  </ul>\n</blockquote>\n<ul>\n  <li>\nbar  </li>\n</ul>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "indented case" do
      markdown = " > - foo\n- bar\n"
      html     = "<blockquote>\n  <ul>\n    <li>\nfoo    </li>\n  </ul>\n</blockquote>\n<ul>\n  <li>\nbar  </li>\n</ul>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
