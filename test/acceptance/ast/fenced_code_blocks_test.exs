defmodule Acceptance.Ast.FencedCodeBlocksTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1, as_ast: 2]

  describe "Fenced code blocks" do
    @tag :ast
    test "no lang" do
      markdown = "```\n<\n >\n```\n"
      html     = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "still no lang" do
      markdown = "~~~\n<\n >\n~~~\n"
      html     = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "elixir 's the name" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = "<pre><code class=\"elixir\">aaa\n~~~</code></pre>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "with a code_class_prefix" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = "<pre><code class=\"elixir lang-elixir\">aaa\n~~~</code></pre>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown, code_class_prefix: "lang-") == {:ok, [ast], messages}
    end

    @tag :ast
    test "look mam, more lines" do
      markdown = "   ```\naaa\nb\n  ```\n"
      html     = "<pre><code class=\"\">aaa\nb</code></pre>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
