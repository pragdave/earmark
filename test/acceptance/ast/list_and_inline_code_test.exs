defmodule Acceptance.Ast.ListAndInlineCodeTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import EarmarkAstDsl

  describe "List parsing running into EOI inside inline code" do
    test "simple case" do
      markdown = ~s(* And\n`Hello\n* World)
      ast      = tag("ul", [tag("li", "And\n`Hello"), tag("li", "World")])
      messages = [{:warning, 2, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "link with title" do
      markdown = ~s(* And\n* `Hello\n* World)
      ast      = tag("ul", [tag("li", "And"), tag("li","`Hello\n* World")])
      messages = [{:warning, 2, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "error in spaced part" do
      markdown = ~s(* And\n  `Hello\n   * World)
      ast      = tag("ul", tag("li", "And\n`Hello\n * World"))
      messages = [{:warning, 2, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "error in doubly spaced part" do
      markdown = ~s(* And\n\n  `Hello\n   * World)
      ast      = tag("ul", tag("li", ["And", "`Hello\n * World"]))
      messages = [{:warning, 3, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "even more complex spaced example (checking for one offs)" do
      markdown = ~s(Prefix1\n* And\n\n  Prefix2\n  `Hello\n   * World)
      ast      = [p("Prefix1"), tag("ul", tag("li", ["And", "Prefix2\n`Hello\n * World"]))]
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
      ast      = [tag("ol", tag("li", [p("one"), tag("pre", tag("code", " defmodule", class: "elixir"))])), pre_code("")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "more aligned fence is part of the inlinde code block" do
      markdown = "  1. one\n    ~~~elixir\n    defmodule\n        ~~~"
      ast      = tag("ol", tag("li", ["one", tag("pre", tag("code", ["defmodule"], [{"class", "elixir"}]))]))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end
end
