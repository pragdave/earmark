defmodule Acceptance.Html1.LinkImages.ImgTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Image reference definitions" do

    test "img with title" do
      markdown = "[foo]: /url \"title\"\n\n![foo]\n"
      html = "<p>\n  <img src=\"/url\" alt=\"foo\" title=\"title\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "this ain't no img (and no link)" do
      markdown = "[foo]: /url \"title\"\n\n![bar]\n"
      html = "<p>\n  ![bar]\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end

  describe "Link and Image imbrication" do

    test "as with this img" do
      markdown = "![[text](inner)](outer)"
      html = "<p>\n  <img src=\"outer\" alt=\"[text](inner)\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "again escapes do not escape us" do
      markdown = "![\\[text\\](inner)](outer)"
      html = "<p>\n  <img src=\"outer\" alt=\"[text](inner)\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end


    test "a lonely moon" do
      markdown = "![moon](moon.jpg)\n"
      html = "<p>\n  <img src=\"moon.jpg\" alt=\"moon\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "headaches ahead (and behind us)" do
      markdown = "[![moon](moon.jpg)](/uri)\n"
      html = "<p>\n  <a href=\"/uri\">\n    <img src=\"moon.jpg\" alt=\"moon\" />\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "lost in space" do
      markdown = "![![moon](moon.jpg)](sun.jpg)\n"
      html = "<p>\n  <img src=\"sun.jpg\" alt=\"![moon](moon.jpg)\" />\n</p>\n"
      messages = []
      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "Images" do

    test "title" do
      markdown = "![foo](/url \"title\")\n"
      html = "<p>\n  <img src=\"/url\" alt=\"foo\" title=\"title\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "parens: images" do
      markdown =  "(![text](src))"
      html = ~s{<p>\n  (\n  <img src="src" alt="text" />\n  )\n</p>\n}
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "ti tle (why not)" do
      markdown = "![foo](/url \"ti tle\")\n"
      html = "<p>\n  <img src=\"/url\" alt=\"foo\" title=\"ti tle\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "titles become strange" do
      markdown = "![foo](/url \"ti() tle\")\n"
      html = "<p>\n  <img src=\"/url\" alt=\"foo\" title=\"ti() tle\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "as does everything else" do
      markdown = "![f[]oo](/url \"ti() tle\")\n"
      html = "<p>\n  <img src=\"/url\" alt=\"f[]oo\" title=\"ti() tle\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "alt goes crazy" do
      markdown = "![foo[([])]](/url 'title')\n"
      html = "<p>\n  <img src=\"/url\" alt=\"foo[([])]\" title=\"title\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "alt goes crazy, with deprecation warnings" do
      markdown = "\n![foo[([])]](/url 'title\")\n"
      html = "<p>\n  <img src=\"/url%20&#39;title%22\" alt=\"foo[([])]\" />\n</p>\n"

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "url escapes of course" do
      markdown = "![foo](/url no title)\n"
      html = "<p>\n  <img src=\"/url%20no%20title\" alt=\"foo\" />\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end

end

# SPDX-License-Identifier: Apache-2.0
