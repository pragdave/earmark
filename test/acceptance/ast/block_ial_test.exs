defmodule Acceptance.Ast.BlockIalTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl

  describe "IAL" do

    test "Not associated" do
      markdown = "{:hello=world}"
      ast      = p("{:hello=world}")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Not associated means verbatim" do
      markdown = "{: hello=world  }"
      ast      = p("{: hello=world  }")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Not associated and incorrect" do
      markdown = "{:hello}"
      ast      = tag("p", "{:hello}")
      messages = [{:warning, 1, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "Associated" do
      markdown = "Before\n{:hello=world}"
      ast      = tag("p", "Before", hello: "world")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Associated in between" do
      markdown = "Before\n{:hello=world}\nAfter"
      ast      = [p("Before", hello: "world"), p("After")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "Associated and incorrect" do
      markdown = "Before\n{:hello}"
      ast      = tag("p", "Before")
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "Associated and partly incorrect" do
      markdown = "Before\n{:hello title=world}"
      ast      = p("Before", title: "world")
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "Associated and partly incorrect and shortcuts" do
      markdown = "Before\n{:#hello .alpha hello title=world .beta class=\"gamma\" title='class'}"
      ast      = p("Before", class: "gamma beta alpha", id: "hello", title: "class world")
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    # https://github.com/pragdave/earmark/issues/367
    @tag :wip
    test "In tight lists?" do
      markdown = "- Before\n{:.alpha .beta}"
      ast      = tag("ul", tag("li", "Before", class: "beta alpha"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
