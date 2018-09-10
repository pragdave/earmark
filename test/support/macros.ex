defmodule Support.Macros do

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
    end
  end
  
  defmacro assert_ast(markdown, expected_ast, messages \\ [])
  defmacro assert_ast(markdown, expected_ast, []) do
    ExUnit.Case.test "expect #{markdown} to parse to #{inspect expected_ast}" do
      ExUnit.Assertions.assert Earmark2.as_ast(markdown) == {:ok, expected_ast, []}
    end
  end
  defmacro assert_ast(markdown, expected_ast, messages) do
    ExUnit.Case.test "expect #{markdown} to parse to #{inspect expected_ast} with #{inspect messages}" do
      ExUnit.Assertions.assert Earmark2.as_ast(markdown) == {:error, expected_ast, messages}
    end
  end
end
