defmodule Acceptance.Html.LinksImages.SimplePureLinksTest do
  use Support.AcceptanceTestCase

  describe "simple pure links not yet enabled" do
    test "old behavior" do
      markdown = "https://github.com/pragdave/earmark"
      html     = "<p>\nhttps://github.com/pragdave/earmark</p>\n"
      messages = []

      assert as_html(markdown, pure_links: false) == {:ok, html, messages}
    end
  end

  describe "enabled pure links" do
    test "two in a row" do
      url1 = "https://github.com/pragdave/earmark"
      url2 = "https://github.com/RobertDober/extractly"
      markdown = "#{url1} #{url2}"
       html = "<p>\n<a href=\"https://github.com/pragdave/earmark\">https://github.com/pragdave/earmark</a><a href=\"https://github.com/RobertDober/extractly\">https://github.com/RobertDober/extractly</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
