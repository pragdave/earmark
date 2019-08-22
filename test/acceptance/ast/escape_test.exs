defmodule Acceptance.Ast.EscapeTest do
  use ExUnit.Case
  import Support.Helpers, only: [as_ast: 1, as_ast: 2]

  @moduletag :ast

  describe "Escapes" do
    test "dizzy rhs?" do
      markdown = "\\\\!\\\\\""
      html     = "<p>\\!\\\"</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown, smartypants: true) == {:ok, [ast], messages}
    end

    test "dizzy? lhs" do
      markdown = "\\\\!\\\\\""
      html     = "<p>\\!\\\"</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown, smartypants: false) == {:ok, [ast], messages}
    end

    test "obviously" do
      markdown = "\\`no code"
      html     = "<p>`no code</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "less obviously - escpe the escapes" do
      markdown = "\\\\` code`"
      html     = "<p>\\<code class=\"inline\">code</code></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "don't ask me" do
      markdown = "\\\\ \\"
      html     = "<p>\\ \\</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "a plenty of nots" do
      markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
      html     = "<p>*not emphasized*\n[not a link](/foo)\n`not code`\n1. not a list\n* not a list\n# not a header\n[foo]: /url &quot;not a reference&quot;</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = [{:warning, 3, "Closing unclosed backquotes ` at end of input" }]

      assert as_ast(markdown, smartypants: false) == {:error, [ast], messages}
    end

    test "let us escape (again)" do
      markdown = "\\\\*emphasis*\n"
      html = "<p>\\<em>emphasis</em></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
