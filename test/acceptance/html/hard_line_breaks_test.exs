defmodule Acceptance.Html.HardLineBreaksTest do
  use Support.AcceptanceTestCase

  describe "gfm" do 
    test "hard line breaks are enabled" do 
      markdown = "line 1\nline 2\\\nline 3"
      html     = para(["line 1\nline 2", :br, "line 3"])
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "no gfm" do 
    test "hard line breaks are not enabled" do 
      markdown = "line 1\nline 2\\\nline 3"
      html     = para("line 1\nline 2\\\nline 3")
      messages = []

      assert as_html(markdown, gfm: false) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
