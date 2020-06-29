defmodule Acceptance.Html.LineBreaksTest do
  use Support.AcceptanceTestCase

  describe "Forced Line Breaks" do
    test "with two spaces" do
      markdown = "The  \nquick"
      html     = "<p>\nThe  <br />\nquick</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "No Forced Line Breaks" do
    test "or inside the line" do
      markdown = "The  quick\nbrown"
      html     = "<p>\nThe  quick\nbrown</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "or in code blocks" do
      markdown = "```\nThe  \nquick\n```"
      html     = "<pre><code>The  \nquick</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
