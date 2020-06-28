defmodule Acceptance.Ast.DiverseTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl

  describe "etc" do
    test "entiy" do
      markdown = "`f&ouml;&ouml;`\n"
      ast      = p(tag("code", "f&ouml;&ouml;", class: "inline"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "spaec preserving" do
      markdown = "Multiple     spaces\n"
      ast      = p("Multiple     spaces")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "syntax errors" do
      markdown ="A\nB\n="
      ast      = [p("A\nB"), p([])]
      messages = [{:warning, 3, "Unexpected line =" }]

      assert as_ast(markdown) == {:error, ast, messages}
    end
   end

end

# SPDX-License-Identifier: Apache-2.0
