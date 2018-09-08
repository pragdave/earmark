defmodule Earmark2.Acceptance.ParaTest do
  use ExUnit.Case

  describe "simple para" do

    test "nothing at all" do
      assert ok_ast("") == []
    end
    test "single line" do
      assert ok_ast("Hello World") == [{:p, [], [{:text, [], "Hello World"}]}]
    end
  end
  

  defp ok_ast text do
    with {:ok, ast, []} <- Earmark2.as_ast(text), do: ast
  end
end
