defmodule Acceptance.Ast.ListAndInlineCodeTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

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

  describe "indention of code (was regtest #85)" do
    test "loosing som indent" do
      markdown = "1. one\n\n    ```elixir\n    defmodule```\n"
      html     = "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\"> defmodule```</code></pre>\n</li>\n</ol>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "less aligned fence is not part of the inline code block" do
      markdown = "1. one\n\n    ~~~elixir\n    defmodule\n  ~~~"
      ast      = [
                {"ol", '', [{"li", '', [{"p", '', ["one"]}, {"pre", '', [{"code", [{"class", "elixir"}], [" defmodule"]}]}]}]},
                {"pre", [], [{"code", [], [""]}]}
              ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "more aligned fence is part of the inlinde code block" do
      markdown = "  1. one\n    ~~~elixir\n    defmodule\n        ~~~"
      ast      = [{"ol", [], [{"li", [], ["one", {"pre", [], [{"code", [{"class", "elixir"}], ["defmodule"]}]}]}]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end
