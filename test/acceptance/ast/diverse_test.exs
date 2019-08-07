defmodule Acceptance.Ast.DiverseTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1]

  describe "etc" do
    @tag :ast
    test "entiy" do
      markdown = "`f&ouml;&ouml;`\n"
      html     = "<p><code class=\"inline\">f&amp;ouml;&amp;ouml;</code></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "spaec preserving" do
      markdown = "Multiple     spaces\n"
      html     = "<p>Multiple     spaces</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "syntax errors" do
      markdown ="A\nB\n="
      html     = "<p>A\nB</p>\n<p></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = [{:warning, 3, "Unexpected line =" }]

      assert as_ast(markdown) == {:error, ast, messages}
    end
   end

end

# SPDX-License-Identifier: Apache-2.0
