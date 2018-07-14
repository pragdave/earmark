defmodule Ast.ParagraphsTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_ast: 1]

  describe "Paragraphs" do
    test "a para" do
      markdown = "aaa\n\nbbb\n"
      ast = [{"p", [], ["aaa"]}, {"p", [], ["bbb"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "and another one" do
      markdown = "aaa\n\n\nbbb\n"
      ast = [{"p", [], ["aaa"]}, {"p", [], ["bbb"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

  end
end
