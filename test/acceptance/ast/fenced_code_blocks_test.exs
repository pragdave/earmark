defmodule Acceptance.Ast.FencedCodeBlocksTest do
  use ExUnit.Case
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]
  
  @moduletag :ast

  describe "Fenced code blocks" do
    test "no lang" do
      markdown = "```\n<\n >\n```\n"
      html     = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "still no lang" do
      markdown = "~~~\n<\n >\n~~~\n"
      html     = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "elixir 's the name" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = "<pre><code class=\"elixir\">aaa\n~~~</code></pre>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "with a code_class_prefix" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = "<pre><code class=\"elixir lang-elixir\">aaa\n~~~</code></pre>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, code_class_prefix: "lang-") == {:ok, [ast], messages}
    end

    test "look mam, more lines" do
      markdown = "   ```\naaa\nb\n  ```\n"
      html     = "<pre><code class=\"\">aaa\nb</code></pre>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
