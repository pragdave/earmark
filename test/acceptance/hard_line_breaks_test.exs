defmodule Acceptance.HardLineBreaksTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_html: 1, as_html: 2]
  describe "gfm" do 
    test "hard line breaks are enabled" do 
      
      markdown = "line 1\nline 2\\\nline 3"
      html     = "<p>line 1\nline 2<br>\nline 3</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "hard line breaks are enabled only inside paras" do 
      
      markdown = "line 1\nline 2\\\n\nline 3"
      html     = "<p>line 1\nline 2\\</p>\n<p>line 3</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "hard line breaks are not enabled at the end" do 
      
      markdown = "line 1\nline 2\\\n"
      html     = "<p>line 1\nline 2\\</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "no gfm" do 
    test "hard line breaks are not enabled" do 
      
      markdown = "line 1\nline 2\\\nline 3"
      html     = "<p>line 1\nline 2\\\nline 3</p>\n"
      messages = []

      assert as_html(markdown, gfm: false) == {:ok, html, messages}
    end

    test "hard line breaks are enabled only inside paras" do 
      
      markdown = "line 1\nline 2\\\n\nline 3"
      html     = "<p>line 1\nline 2\\</p>\n<p>line 3</p>\n"
      messages = []

      assert as_html(markdown, gfm: false) == {:ok, html, messages}
    end

    test "hard line breaks are not enabled at the end" do 
      
      markdown = "line 1\nline 2\\\n"
      html     = "<p>line 1\nline 2\\</p>\n"
      messages = []

      assert as_html(markdown, gfm: false) == {:ok, html, messages}
    end
  end


end

# SPDX-License-Identifier: Apache-2.0
