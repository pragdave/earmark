defmodule Acceptance.Ast.BlockIalTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  describe "IAL" do

    test "Not associated" do
      markdown = "{:hello=world}"
      html     = "<p>{:hello=world}</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Not associated means verbatim" do
      markdown = "{: hello=world  }"
      html     = "<p>{: hello=world  }</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Not associated and incorrect" do
      markdown = "{:hello}"
      html     = "<p>{:hello}</p>\n"
      ast      = parse_html(html)
      messages = [{:warning, 1, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "Associated" do
      markdown = "Before\n{:hello=world}"
      ast     = "<p hello=\"world\">Before</p>\n" |> Floki.parse
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Associated in between" do
      markdown = "Before\n{:hello=world}\nAfter"
      html     = "<p hello=\"world\">Before</p>\n<p>After</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "Associated and incorrect" do
      markdown = "Before\n{:hello}"
      html     = "<p>Before</p>\n"
      ast      = parse_html(html)
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "Associated and partly incorrect" do
      markdown = "Before\n{:hello title=world}"
      html     = "<p title=\"world\">Before</p>\n"
      ast      = parse_html(html)
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "Associated and partly incorrect and shortcuts" do
      markdown = "Before\n{:#hello .alpha hello title=world .beta class=\"gamma\" title='class'}"
      html     = "<p class=\"gamma beta alpha\" id=\"hello\" title=\"class world\">Before</p>\n"
      ast      = parse_html(html)
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
