defmodule Acceptance.Ast.EmptyTest do
  use ExUnit.Case

  @moduletag :ast

  test "empty" do
    markdown = ""
    ast     = []
    messages = []

    assert Earmark.as_ast(markdown) == {:ok, ast, messages}
  end

  test "almost empty" do
    markdown = "  "
    ast     = []
    messages = []

    assert Earmark.as_ast(markdown) == {:ok, ast, messages}
  end
  
end
