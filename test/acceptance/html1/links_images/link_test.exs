defmodule Acceptance.Html1.LinkImages.LinkTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Link reference definitions" do
    test "link with title" do
      markdown = "[foo]: /url \"title\"\n\n[foo]\n"
      html = "<p>\n  <a href=\"/url\" title=\"title\">\n    foo\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "link with utf8 title" do
      markdown = "[foo]: /url \"Überschrift\"\n\n[foo]\n"
      html = "<p>\n  <a href=\"/url\" title=\"Überschrift\">\n    foo\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "this ain't no link" do
      markdown = "[foo]: /url \"title\"\n\n[bar]\n"
      html = "<p>\n  [bar]\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "strange syntaxes exist in Markdown" do
      markdown = "[foo]\n\n[foo]: url\n"
      html = "<p>\n  <a href=\"url\" title=\"\">\n    foo\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "sometimes strange text is just strange text - stupid pants" do
      markdown = "[foo]: /url \"title\" ok\n"
      html = "<p>\n  [foo]: /url &quot;title&quot; ok\n</p>\n"
      messages = []

      assert to_html1(markdown, smartypants: false) == {:ok, html, messages}
    end

    test "sometimes strange text is just strange text - smart pants" do
      markdown = "[foo]: /url \"title\" ok\n"
      html = "<p>\n  [foo]: /url “title” ok\n</p>\n"
      messages = []

      assert to_html1(markdown, smartypants: true) == {:ok, html, messages}
    end

    test "guess how this one is rendered?" do
      markdown = "[foo]: /url \"title\"\n"
      html = ""
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "or this one, but you might be wrong" do
      markdown = "# [Foo]\n[foo]: /url\n> bar\n"

      html = [
        "<h1>", 
        "  <a href=\"/url\" title=\"\">",
        "    Foo",
        "  </a>",
        "</h1>",
        "<blockquote>",
        "  <p>",
        "    bar",
        "  </p>",
        "</blockquote>\n" ] |> Enum.join("\n")

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "Link and Image imbrication" do
    test "empty (remains such)" do
      markdown = ""
      html = ""
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "inner is a link, not outer" do
      markdown = "[[text](inner)]outer"
      html = [
        "<p>",
        "  [",
        "  <a href=\"inner\">",
        "    text",
        "  </a>",
        "  ]outer",
        "</p>\n"] |> Enum.join("\n")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "unless your outer is syntactically a link of course" do
      markdown = "[[text](inner)](outer)"
      html = [
        "<p>",
        "  <a href=\"outer\">",
        "    [text](inner)",
        "  </a>",
        "</p>\n"] |> Enum.join("\n")

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "escaping does not change that" do
      markdown = "[\\[text\\](inner\\)](outer)"
      html = [
        "<p>",
        "  <a href=\"outer\">",
        "    [text](inner)",
        "  </a>",
        "</p>\n"] |> Enum.join("\n")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end

  describe "Links" do

    test "no title" do
      markdown = "[link](/uri))\n"
      html = "<p>\n  <a href=\"/uri\">\n    link\n  </a>\n  )\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "let's go nowhere" do
      markdown = "[link]()\n"
      html = "<p>\n  <a href=\"\">\n    link\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "nowhere in a bottle" do
      markdown = "[link](())\n"
      html = "<p>\n  <a href=\"()\">\n    link\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "minimal case" do
      markdown = "([]()"
      html = "<p>\n  (\n  <a href=\"\"></a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "minimal case, ) as suffix" do
      markdown = "([]())"
      html = "<p>\n  (\n  <a href=\"\"></a>\n  )\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "normal case" do
      markdown = "([text](link))"
      html     = "<p>\n  (\n  <a href=\"link\">\n    text\n  </a>\n  )\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end


  describe "Autolinks" do
    test "that was easy" do
      markdown = "<http://foo.bar.baz>\n"
      html = "<p>\n  <a href=\"http://foo.bar.baz\">\n    http://foo.bar.baz\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "as was this" do
      markdown = "<irc://foo.bar:2233/baz>\n"
      html = "<p>\n  <a href=\"irc://foo.bar:2233/baz\">\n    irc://foo.bar:2233/baz\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "good ol' mail" do
      markdown = "<mailto:foo@bar.baz>\n"
      html = "<p>\n  <a href=\"mailto:foo@bar.baz\">\n    foo@bar.baz\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "we know what mail is" do
      markdown = "<foo@bar.example.com>\n"
      html = "<p>\n  <a href=\"mailto:foo@bar.example.com\">\n    foo@bar.example.com\n  </a>\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "not really a link" do
      markdown = "<>\n"
      html = "<p>\n  &lt;&gt;\n</p>\n"
      messages = []
      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
