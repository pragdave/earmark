defmodule Acceptance.Ast.EscapeTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1, as_html: 2]

  # describe "Escapes" do
    test "dizzy?" do
      markdown = "\\\\!\\\\\""
      html     = "<p>\\!\\“</p>\n"
      messages = []

      assert as_html(markdown, smartypants: true) == {:ok, html, messages}

      html     = "<p>\\!\\&quot;</p>\n"
      assert as_html(markdown, smartypants: false) == {:ok, html, messages}
    end

    test "obviously" do
      markdown = "\\`no code"
      html     = "<p>`no code</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "less obviously - escpe the escapes" do
      markdown = "\\\\` code`"
      html     = "<p>\\<code class=\"inline\">code</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "don't ask me" do
      markdown = "\\\\ \\"
      html     = "<p>\\ \\</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "a plenty of nots" do
      markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
      html     = "<p>*not emphasized*\n[not a link](/foo)\n`not code`\n1. not a list\n* not a list\n# not a header\n[foo]: /url &quot;not a reference&quot;</p>\n"
      messages = [{:warning, 3, "Closing unclosed backquotes ` at end of input" }]

      assert as_html(markdown, smartypants: false) == {:error, html, messages}
    end

    test "let us escape (again)" do
      markdown = "\\\\*emphasis*\n"
      html = "<p>\\<em>emphasis</em></p>\n"
      messages = []
      assert as_html(markdown) == {:ok, html, messages}
    end
  # end
end

# SPDX-License-Identifier: Apache-2.0
