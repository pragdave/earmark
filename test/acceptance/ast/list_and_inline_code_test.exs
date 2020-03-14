defmodule Acceptance.Ast.ListAndInlineCodeTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]

  describe "List parsing running into EOI inside inline code" do
    test "simple case" do
      markdown = ~s(* And\n`Hello\n* World)
      ast      = [{"ul", '', [{"li", '', ["And\n`Hello"]}, {"li", '', ["World"]}]}] 
      messages = [{:warning, 2, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end

    test "link with title" do
      markdown = ~s(* And\n* `Hello\n* World)
      ast      = {"ul", [], [{"li", [], ["And"]}, {"li", [], ["`Hello\n* World"]}]}
      messages = [{:warning, 2, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "error in spaced part" do
      markdown = ~s(* And\n  `Hello\n   * World)
      ast      = [{"ul", '', [{"li", '', ["And\n`Hello\n * World"]}]}]
      messages = [{:warning, 2, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end

    test "error in doubly spaced part" do
      markdown = ~s(* And\n\n  `Hello\n   * World)
      ast      = [{"ul", '', [{"li", '', ["And", "`Hello\n * World"]}]}]
      messages = [{:warning, 3, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end

    test "even more complex spaced example (checking for one offs)" do
      markdown = ~s(Prefix1\n* And\n\n  Prefix2\n  `Hello\n   * World)
      ast      = [{"p", '', ["Prefix1"]}, {"ul", [], [{"li", [], ["And", "Prefix2\n`Hello\n * World"]}]}]
      messages = [{:warning, 5, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end
  end
end
