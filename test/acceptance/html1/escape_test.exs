defmodule Acceptance.Html1.EscapeTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Escapes" do
    # The following case is an example of dependency between parsing and inline rendering
    # resolved by a regex I do not understand; therefore, to remain sane, I'll ignore it
    # for this release, that is why ast and transformer support is still experimental!!!!
    @tag :wip
    test "dizzy?" do
      markdown = "\\\\!\\\\\""
      html     = para("\\!\\“")
      messages = []

      assert to_html1(markdown, smartypants: true) == {:ok, html, messages}
    end

    test "dizzier?" do
      markdown = "\\\\!\\\\\""
      html     = para("\\!\\&quot;")
      messages = []

      assert to_html1(markdown, smartypants: false) == {:ok, html, messages}
    end

    test "obviously" do
      markdown = "\\`no code"
      html     = para("`no code")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "less obviously - escpe the escapes" do
      markdown = "\\\\` code`"
      html     = para([ "\\", {:code, ~s{class="inline"}}, "code" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "don't ask me" do
      markdown = "\\\\ \\"
      html     = para("\\ \\")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "a plenty of nots" do
      markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
      html     = para(["*not emphasized*\n[not a link](/foo)\n`not code`\n1. not a list\n* not a list\n# not a header\n[foo]: /url &quot;not a reference&quot;" ])
      messages = [{:warning, 3, "Closing unclosed backquotes ` at end of input" }]

      assert to_html1(markdown, smartypants: false) == {:error, html, messages}
    end

    test "let us escape (again)" do
      markdown = "\\\\*emphasis*\n"
      html     = para([ "\\", :em, "emphasis" ])
      messages = []
      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
