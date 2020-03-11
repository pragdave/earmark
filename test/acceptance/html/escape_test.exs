defmodule Acceptance.Html.EscapeTest do
  use Support.AcceptanceTestCase

  describe "Escapes" do
    test "dizzy?" do
      markdown = "\\\\!\\\\\""
      html     = "<p>\n  \\!\\”\n</p>\n"
      messages = []

      assert as_html(markdown, smartypants: true) == {:ok, html, messages}
    end

    test "dizzy and not smart :O" do
      markdown = "\\\\!\\\\\""
      html     = "<p>\n  \\!\\&quot;\n</p>\n"
      messages = []

      assert as_html(markdown, smartypants: false) == {:ok, html, messages}
    end

    test "less obviously - escpe the escapes" do
      markdown = "\\\\` code`"
      html     = "<p>\n  \\\n<code class=\"inline\">code</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
