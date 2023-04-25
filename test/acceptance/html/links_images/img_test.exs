defmodule Acceptance.Html.LinkImages.ImgTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_html: 1]

  describe "Image reference definitions" do
    test "img with title" do
      markdown = "[foo]: /url \"title\"\n\n![foo]\n"
      html = "<p>\n  <img src=\"/url\" alt=\"foo\" title=\"title\">\n</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Link and Image imbrication" do
    test "as with this img" do
      markdown = "![[text](inner)](outer)"
      html = "<p>\n  <img src=\"outer\" alt=\"[text](inner)\">\n</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "a lonely moon" do
      markdown = "![moon](moon.jpg)\n"
      html = "<p>\n  <img src=\"moon.jpg\" alt=\"moon\">\n</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Images" do
    test "title" do
      markdown = "![foo](/url \"title\")\n"
      html = "<p>\n  <img src=\"/url\" alt=\"foo\" title=\"title\">\n</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "parens: images" do
      result = Earmark.as_html!("(![text](src))")
      html = "<p>\n(  <img src=\"src\" alt=\"text\">\n)</p>\n"

      assert result == html
    end

    test "as does everything else" do
      markdown = "![f[]oo](/url \"ti() tle\")\n"
      html = "<p>\n  <img src=\"/url\" alt=\"f[]oo\" title=\"ti() tle\">\n</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
