defmodule Acceptance.Ast.BlockIalTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1, as_html: 1]

   describe "IAL" do

     @tag :ast
    test "Not associated" do
      markdown = "{:hello=world}"
      html     = "<p>{:hello=world}</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "Not associated means verbatim" do
      markdown = "{: hello=world  }"
      html     = "<p>{: hello=world  }</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "Not associated and incorrect" do
      markdown = "{:hello}"
      html     = "<p>{:hello}</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = [{:warning, 1, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    @tag :ast
    test "Associated" do
      markdown = "Before\n{:hello=world}"
      ast     = "<p hello=\"world\">Before</p>\n" |> Floki.parse
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "Associated in between" do
      markdown = "Before\n{:hello=world}\nAfter"
      html     = "<p hello=\"world\">Before</p>\n<p>After</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "Associated and incorrect" do
      markdown = "Before\n{:hello}"
      html     = "<p>Before</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    @tag :ast
    test "Associated and partly incorrect" do
      markdown = "Before\n{:hello title=world}"
      html     = "<p title=\"world\">Before</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    @tag :ast
    test "Associated and partly incorrect and shortcuts" do
      markdown = "Before\n{:#hello .alpha hello title=world .beta class=\"gamma\" title='class'}"
      html     = "<p class=\"gamma beta alpha\" id=\"hello\" title=\"class world\">Before</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
