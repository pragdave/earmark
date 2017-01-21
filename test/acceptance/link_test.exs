defmodule Acceptance.LinkTest do
  use ExUnit.Case
  
    describe "Link reference definitions" do
      test "link with title" do
        markdown = "[foo]: /url \"title\"\n\n[foo]\n"
        html     = "<p><a href=\"/url\" title=\"title\">foo</a></p>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "this ain't no link" do
        markdown = "[foo]: /url \"title\"\n\n[bar]\n"
        html     = "<p>[bar]</p>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "img with title" do
        markdown = "[foo]: /url \"title\"\n\n![foo]\n"
        html     = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "this ain't no img (and no link)" do
        markdown = "[foo]: /url \"title\"\n\n![bar]\n"
        html     = "<p>![bar]</p>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "strange syntaxes exist in Markdown" do
        markdown = "[foo]\n\n[foo]: url\n"
        html = "<p><a href=\"url\" title=\"\">foo</a></p>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "sometimes strange text is just strange text" do
        markdown = "[foo]: /url \"title\" ok\n"
        html     = "<p>[foo]: /url &quot;title&quot; ok</p>\n"
        messages = []

        assert Earmark.as_html(markdown, %Earmark.Options{smartypants: false}) == {html, messages}

        html     = "<p>[foo]: /url “title” ok</p>\n"
        assert Earmark.as_html(markdown, %Earmark.Options{smartypants: true}) == {html, messages}
      end

      test "guess how this one is rendered?" do
        markdown = "[foo]: /url \"title\"\n"
        html     = ""
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "or this one, but you might be wrong" do
        markdown = "# [Foo]\n[foo]: /url\n> bar\n"
        html     = "<h1><a href=\"/url\" title=\"\">Foo</a></h1>\n<blockquote><p>bar</p>\n</blockquote>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

    end
    describe "Link and Image imbrication" do
      test "empty (remains such)" do
        markdown = ""
        html     = ""
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "inner is a link, not outer" do
        markdown = "[[text](inner)]outer"
        html     = "<p>[<a href=\"inner\">text</a>]outer</p>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "unless your outer is syntactically a link of course" do
        markdown = "[[text](inner)](outer)"
        html = "<p><a href=\"outer\">[text](inner)</a></p>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "as with this img" do
        markdown = "![[text](inner)](outer)"
        html     = "<p><img src=\"outer\" alt=\"[text](inner)\"/></p>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "headaches ahead (and behind us)" do
        markdown = "[![moon](moon.jpg)](/uri)\n"
        html     = "<p><a href=\"/uri\"><img src=\"moon.jpg\" alt=\"moon\"/></a></p>\n"
        messages = []

        assert Earmark.as_html(markdown) == {html, messages}
      end

      test "lost in space" do
        markdown = "![![moon](moon.jpg)](sun.jpg)\n"
        html = "<p><img src=\"sun.jpg\" alt=\"![moon](moon.jpg)\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end
end
