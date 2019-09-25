defmodule Acceptance.Html1.LineBreaksTest do
  use ExUnit.Case, async: true
  
  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Forced Line Breaks" do
    test "with two spaces" do
      markdown = "The  \nquick"
      html     = para([ "The", :br, "quick" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "or more spaces" do
      markdown = "The   \nquick"
      html     = para([ "The", :br, "quick" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "or in some lines" do
      markdown = "The   \nquick  \nbrown"
      html     = para(["The", :br, "quick", :br, "brown"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "and in list items" do
      markdown = "* The  \nquick"
      html     = construct([
        :ul, :li, "The", :br, "quick" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end


  describe "No Forced Line Breaks" do
    test "with only one space" do
      markdown = "The \nquick"
      html     = para("The \nquick")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "or whitspace lines" do
      markdown = "The\n  \nquick"
      html     = construct([
        {:p, nil, "The"},
        {:p, nil, "quick"} ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "or inside the line" do
      markdown = "The  quick\nbrown"
      html     = para("The  quick\nbrown")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "or at the end of input" do
      markdown = "The\nquick  "
      html     = para("The\nquick  ")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "or in code blocks" do
      markdown = "```\nThe  \nquick\n```"
      html     = ~s{<pre><code class="">The  \nquick</code></pre>\n}
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
