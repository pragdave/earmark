defmodule Acceptance.Ast.LineBreaksTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_html: 1]

  describe "Forced Line Breaks" do
    test "with two spaces" do
      markdown = "The  \nquick"
      html     = "<p>The<br>quick</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "or more spaces" do
      markdown = "The   \nquick"
      html     = "<p>The<br>quick</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "or in some lines" do
      markdown = "The   \nquick  \nbrown"
      html     = "<p>The<br>quick<br>brown</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "and in list items" do
      markdown = "* The  \nquick"
      html     = "<ul>\n<li>The<br>quick\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end


  describe "No Forced Line Breaks" do
    test "with only one space" do
      markdown = "The \nquick"
      html     = "<p>The \nquick</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "or whitspace lines" do
      markdown = "The\n  \nquick"
      html     = "<p>The</p>\n<p>quick</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "or inside the line" do
      markdown = "The  quick\nbrown"
      html     = "<p>The  quick\nbrown</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "or at the end of input" do
      markdown = "The\nquick  "
      html     = "<p>The\nquick  </p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "or in code blocks" do
      markdown = "```\nThe \nquick\n```"
      html     = "<pre><code class=\"\">The \nquick</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
