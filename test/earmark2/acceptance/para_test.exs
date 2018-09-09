defmodule Earmark2.Acceptance.ParaTest do
  use ExUnit.Case

  describe "simple para" do

    test "single line" do
      assert ok_ast("Hello World") == [{:p, [], [{:text, [], "Hello World"}]}]
    end

    test "indented single line" do
      assert ok_ast("    Hello World") == [{:pre, [], [{:code, [], "Hello World"}]}]
    end

    test "setext, beloved setext" do
      assert ok_ast("Hello World\n===") == [{:h1, [], "Hello World"}]
    end
  end
  

  defp ok_ast text do
    with {:ok, ast, []} <- Earmark2.as_ast(text), do: ast
  end
end
