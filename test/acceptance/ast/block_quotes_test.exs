defmodule Acceptance.Ast.BlockQuotesTest do
  use ExUnit.Case

  # describe "Block Quotes" do
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

  # end
end

# SPDX-License-Identifier: Apache-2.0
