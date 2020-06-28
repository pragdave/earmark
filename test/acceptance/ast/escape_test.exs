defmodule Acceptance.Ast.EscapeTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2]
  import EarmarkAstDsl

  describe "Escapes" do
    test "dizzy rhs?" do
      markdown = "\\\\!\\\\\""
      ast      = p("\\!\\\"")
      messages = []

      assert as_ast(markdown, smartypants: true) == {:ok, [ast], messages}
    end

    test "dizzy? lhs" do
      markdown = "\\\\!\\\\\""
      ast      = p("\\!\\\"")
      messages = []

      assert as_ast(markdown, smartypants: false) == {:ok, [ast], messages}
    end

    test "obviously" do
      markdown = "\\`no code"
      ast      = p("`no code")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "less obviously - escpe the escapes" do
      markdown = "\\\\` code`"
      ast      = p(["\\", tag("code", "code", class: "inline")])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "don't ask me" do
      markdown = "\\\\ \\"
      ast      = p("\\ \\")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "a plenty of nots" do
      markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
      ast      = p(["*not emphasized*\n[not a link](/foo)\n`not code`\n1. not a list\n* not a list\n# not a header\n[foo]: /url \"not a reference\""])
      messages = [{:warning, 3, "Closing unclosed backquotes ` at end of input" }]

      assert as_ast(markdown, smartypants: false) == {:error, [ast], messages}
    end

    test "let us escape (again)" do
      markdown = "\\\\*emphasis*\n"
      ast      = p(["\\", tag("em", "emphasis")])
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
