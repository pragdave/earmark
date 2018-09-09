defmodule Ast.BlockQuotesTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1]

  # describe "Block Quotes" do
    test "quote my block" do
      markdown = "> Foo"
      ast = {"blockquote", [], [{"p", [], ["Foo"]}]}
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "and block my quotes" do
      markdown = "> # Foo\n> bar\n> baz\n"
      ast = {"blockquote", [], [{"h1", [], ["Foo"]}, {"p", [], ["bar\nbaz"]}]}
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "linient we are" do
      markdown = "> bar\nbaz\n> foo\n"
      ast = {"blockquote", [], [{"p", [], ["bar\nbaz\nfoo"]}]}
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "lists in blockquotes? Coming up Sir" do
      markdown = "> - foo\n- bar\n"
      ast = [{"blockquote", [], [{"ul", [], [{"li", [], ["foo"]}]}]}, {"ul", [], [{"li", [], ["bar"]}]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

  # end
end