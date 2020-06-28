defmodule Acceptance.Ast.FencedCodeBlocksTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2]
  import EarmarkAstDsl
  
  describe "Fenced code blocks" do
    test "no lang" do
      markdown = "```\n<\n >\n```\n"
      ast      = pre_code("<\n >")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "still no lang" do
      markdown = "~~~\n<\n >\n~~~\n"
      ast      = pre_code("<\n >")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "longer with shorter inside" do
      markdown = "~~~~\n<\n~~~\nsome code\n ~~~\n >\n~~~~\n"
      ast      = pre_code("<\n~~~\nsome code\n ~~~\n >")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "elixir 's the name" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      ast      = tag("pre", tag("code", "aaa\n~~~", class: "elixir"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "elixir with longer fence" do
      markdown = "`````elixir\n````\n```\n````\n`````"
      ast      = tag("pre", tag("code", "````\n```\n````", class: "elixir"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "with a code_class_prefix" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      ast      = tag("pre", tag("code", "aaa\n~~~", class: "elixir lang-elixir"))
      messages = []

      assert as_ast(markdown, code_class_prefix: "lang-") == {:ok, [ast], messages}
    end

    test "with more code_class_preficis" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      ast      = tag("pre", tag("code", "aaa\n~~~", class: "elixir lang-elixir syntax-elixir"))
      messages = []

      assert as_ast(markdown, code_class_prefix: "lang- syntax-") == {:ok, [ast], messages}
    end

    test "look mam, more lines" do
      markdown = "   ```\naaa\nb\n  ```\n"
      ast      = pre_code("aaa\nb")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
