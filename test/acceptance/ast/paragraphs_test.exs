defmodule Acceptance.Ast.ParagraphsTest do
  use ExUnit.Case, async: true
  
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  @moduletag :ast

  describe "Paragraphs" do
    test "a para" do
      markdown = "aaa\n\nbbb\n"
      html     = "<p>aaa</p>\n<p>bbb</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "and another one" do
      markdown = "aaa\n\n\nbbb\n"
      html     = "<p>aaa</p>\n<p>bbb</p>\n"
      ast      = parse_html(html)

      messages = []

      assert Earmark.as_ast(markdown) == {:ok, ast, messages}
    end

    test "strong" do
      markdown = "**inside**"
      html     = "<p><strong>inside</strong></p>"
      ast      = parse_html(html)

      messages = []

      assert Earmark.as_ast(markdown) == {:ok, [ast], messages}
    end

    test "striketrhough" do
      markdown = "~~or maybe not?~~"
      html     = "<p><del>or maybe not?</del></p>\n"
      ast      = parse_html(html)

      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
