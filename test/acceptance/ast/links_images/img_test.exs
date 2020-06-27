defmodule Acceptance.Ast.LinkImages.ImgTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import EarmarkAstDsl

  describe "Image reference definitions" do

    test "img with title" do
      markdown = "[foo]: /url \"title\"\n\n![foo]\n"
      html = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "url encoding is **not** our job" do
      markdown = "[foo]: /url?é=42 \"title\"\n\n![foo]\n"
      html = "<p><img src=\"/url?é=42\" alt=\"foo\" title=\"title\" /></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end


    test "this ain't no img (and no link)" do
      markdown = "[foo]: /url \"title\"\n\n![bar]\n"
      html = "<p>![bar]</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end

  describe "Link and Image imbrication" do

    test "as with this img" do
      markdown = "![[text](inner)](outer)"
      html = "<p><img src=\"outer\" alt=\"[text](inner)\"/></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "again escapes do not escape us" do
      markdown = "![\\[text\\](inner)](outer)"
      html = "<p><img src=\"outer\" alt=\"[text](inner)\"/></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "headaches ahead (and behind us)" do
      markdown = "[![moon](moon.jpg)](/uri)\n"
      html = "<p><a href=\"/uri\"><img src=\"moon.jpg\" alt=\"moon\"/></a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "lost in space" do
      markdown = "![![moon](moon.jpg)](sun.jpg)\n"
      html = "<p><img src=\"sun.jpg\" alt=\"![moon](moon.jpg)\"/></p>\n"
      ast      = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "Images" do

    test "title" do
      markdown = "![foo](/url \"title\")\n"
      html = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "ti tle (why not)" do
      markdown = "![foo](/url \"ti tle\")\n"
      html = "<p><img src=\"/url\" alt=\"foo\" title=\"ti tle\"/></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "titles become strange" do
      markdown = "![foo](/url \"ti() tle\")\n"
      html = "<p><img src=\"/url\" alt=\"foo\" title=\"ti() tle\"/></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "as does everything else" do
      markdown = "![f[]oo](/url \"ti() tle\")\n"
      html = "<p><img src=\"/url\" alt=\"f[]oo\" title=\"ti() tle\"/></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "alt goes crazy" do
      markdown = "![foo[([])]](/url 'title')\n"
      html = "<p><img src=\"/url\" alt=\"foo[([])]\" title=\"title\"/></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "alt goes crazy, with deprecation warnings" do
      markdown = "\n![foo[([])]](/url 'title\")\n"
      ast        = p(void_tag("img", src: "/url 'title\"", alt: "foo[([])]"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "url escapes of course" do
      markdown = "![foo](/url no title)\n"
      html = "<p><img src=\"/url no title\" alt=\"foo\"/></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end

end

# SPDX-License-Identifier: Apache-2.0
