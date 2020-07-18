defmodule Acceptance.Ast.EmptyTest do
  use ExUnit.Case, async: true

  @moduletag :ast

  test "empty" do
    markdown = ""
    ast     = []
    messages = []

    assert EarmarkParser.as_ast(markdown) == {:ok, ast, messages}
  end

  test "almost empty" do
    markdown = "  "
    ast     = []
    messages = []

    assert EarmarkParser.as_ast(markdown) == {:ok, ast, messages}
  end
  
end
