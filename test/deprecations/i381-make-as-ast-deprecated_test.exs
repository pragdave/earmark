defmodule Deprecations.I381DeprecatedTest do
  use ExUnit.Case

  describe "as_ast" do
    test "is deprecated" do
      markdown = "immaterial"
      ast = [{"p", [], ["immaterial"], %{}}]

      messages = [
        {:warning, 0,
         "DEPRECATION: Earmark.as_ast will be removed in version 1.5, please use Earmark.Parser.as_ast, which is of the same type"}
      ]

      assert Earmark.as_ast(markdown, []) == {:ok, ast, messages}
    end

    test "and renders correct errors" do
      markdown = "`a"
      ast = [{"p", [], ["`a"], %{}}]

      messages = [
        {:warning, 0,
         "DEPRECATION: Earmark.as_ast will be removed in version 1.5, please use Earmark.Parser.as_ast, which is of the same type"},
        {:warning, 1, "Closing unclosed backquotes ` at end of input"}
      ]

      assert Earmark.as_ast(markdown, []) == {:error, ast, messages}
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
