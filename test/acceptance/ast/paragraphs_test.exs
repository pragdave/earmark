defmodule Acceptance.Ast.ParagraphsTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_html: 1]

  describe "Paragraphs" do
    test "a para" do
      markdown = "aaa\n\nbbb\n"
      html     = "<p>aaa</p>\n<p>bbb</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "and another one" do
      markdown = "aaa\n\n\nbbb\n"
      html     = "<p>aaa</p>\n<p>bbb</p>\n"
      ast      = Floki.parse(html) |> IO.inspect

      messages = []

      assert Earmark.as_ast(markdown) == {:ok, ast, messages}
    end

    test "strong" do
      markdown = "**inside**"
      html     = "<p><strong>inside</strong></p>"
      ast      = Floki.parse(html) |> IO.inspect

      messages = []

      assert Earmark.as_ast(markdown) == {:ok, [ast], messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
