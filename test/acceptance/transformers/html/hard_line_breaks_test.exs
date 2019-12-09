defmodule Acceptance.Transformers.Html.HardLineBreaksTest do
  use ExUnit.Case, async: true
  
  import Support.Html1Helpers
  
  @moduletag :html1
  describe "gfm" do 
    test "hard line breaks are enabled" do 
      markdown = "line 1\nline 2\\\nline 3"
      html     = para([
        "line 1\nline 2",
        :br,
        "line 3" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "hard line breaks are enabled only inside paras" do 
      markdown = "line 1\nline 2\\\n\nline 3"
      html     = construct([
        {:p, nil, "line 1\nline 2\\"}, 
        {:p, nil, "line 3"} ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "hard line breaks are not enabled at the end" do 
      markdown = "line 1\nline 2\\\n"
      html     = para("line 1\nline 2\\")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "no gfm" do 
    test "hard line breaks are not enabled" do 
      markdown = "line 1\nline 2\\\nline 3"
      html     = para("line 1\nline 2\\\nline 3")
      messages = []

      assert to_html1(markdown, gfm: false) == {:ok, html, messages}
    end

    test "hard line breaks are enabled only inside paras" do 
      markdown = "line 1\nline 2\\\n\nline 3"
      html     = construct([
        {:p, nil, "line 1\nline 2\\"},
        {:p, nil, "line 3"}])
      messages = []

      assert to_html1(markdown, gfm: false) == {:ok, html, messages}
    end

    test "hard line breaks are not enabled at the end" do 
      markdown = "line 1\nline 2\\\n"
      html     = para("line 1\nline 2\\")
      messages = []

      assert to_html1(markdown, gfm: false) == {:ok, html, messages}
    end
  end


end

# SPDX-License-Identifier: Apache-2.0
