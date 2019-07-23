defmodule Acceptance.LinkImages.ImgTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1]

  describe "Image reference definitions" do

    test "img with title" do
      markdown = "[foo]: /url \"title\"\n\n![foo]\n"
      html = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "this ain't no img (and no link)" do
      markdown = "[foo]: /url \"title\"\n\n![bar]\n"
      html = "<p>![bar]</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end

  describe "Link and Image imbrication" do

    test "as with this img" do
      markdown = "![[text](inner)](outer)"
      html = "<p><img src=\"outer\" alt=\"[text](inner)\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "again escapes do not escape us" do
      markdown = "![\\[text\\](inner)](outer)"
      html = "<p><img src=\"outer\" alt=\"[text](inner)\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "headaches ahead (and behind us)" do
      markdown = "[![moon](moon.jpg)](/uri)\n"
      html = "<p><a href=\"/uri\"><img src=\"moon.jpg\" alt=\"moon\"/></a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "lost in space" do
      markdown = "![![moon](moon.jpg)](sun.jpg)\n"
      html = "<p><img src=\"sun.jpg\" alt=\"![moon](moon.jpg)\"/></p>\n"
      messages = []
      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Images" do

    test "title" do
      markdown = "![foo](/url \"title\")\n"
      html = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "ti tle (why not)" do
      markdown = "![foo](/url \"ti tle\")\n"
      html = "<p><img src=\"/url\" alt=\"foo\" title=\"ti tle\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "titles become strange" do
      markdown = "![foo](/url \"ti() tle\")\n"
      html = "<p><img src=\"/url\" alt=\"foo\" title=\"ti() tle\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "as does everything else" do
      markdown = "![f[]oo](/url \"ti() tle\")\n"
      html = "<p><img src=\"/url\" alt=\"f[]oo\" title=\"ti() tle\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "alt goes crazy" do
      markdown = "![foo[([])]](/url 'title')\n"
      html = "<p><img src=\"/url\" alt=\"foo[([])]\" title=\"title\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "alt goes crazy, with deprecation warnings" do
      markdown = "\n![foo[([])]](/url 'title\")\n"
      html = "<p><img src=\"/url%20&#39;title%22\" alt=\"foo[([])]\"/></p>\n"

      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "url escapes of course" do
      markdown = "![foo](/url no title)\n"
      html = "<p><img src=\"/url%20no%20title\" alt=\"foo\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end

end

# SPDX-License-Identifier: Apache-2.0
