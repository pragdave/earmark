defmodule Acceptance.Ast.LinkImages.LinkTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1, as_ast: 2, as_html: 1, as_html: 2]

  describe "Link reference definitions" do
    @tag :ast
    test "link with title" do
      markdown = "[foo]: /url \"title\"\n\n[foo]\n" |> IO.inspect
      html = "<p><a href=\"/url\" title=\"title\">foo</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ["", ast], messages}
    end

    @tag :ast
    test "link with utf8 title" do
      markdown = "[foo]: /url \"Überschrift\"\n\n[foo]\n"
      html = "<p><a href=\"/url\" title=\"Überschrift\">foo</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ["", ast], messages}
    end

    @tag :ast
    test "this ain't no link" do
      markdown = "[foo]: /url \"title\"\n\n[bar]\n"
      html = "<p>[bar]</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ["", ast], messages}
    end

    @tag :ast
    test "strange syntaxes exist in Markdown" do
      markdown = "[foo]\n\n[foo]: url\n"
      html = "<p><a href=\"url\" title=\"\">foo</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast, ""], messages}
    end

    @tag :ast
    test "sometimes strange text is just strange text" do
      markdown = "[foo]: /url \"title\" ok\n"
      html = "<p>[foo]: /url &quot;title&quot; ok</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown, smartypants: false) == {:ok, [ast], messages}

      html = "<p>[foo]: /url “title” ok</p>\n"
      assert as_html(markdown, smartypants: true) == {:ok, html, messages}
    end

    @tag :ast
    test "guess how this one is rendered?" do
      markdown = "[foo]: /url \"title\"\n"
      html = ""
      messages = []

      assert as_ast(markdown) == {:ok, [""], messages}
    end

    @tag :ast
    test "or this one, but you might be wrong" do
      markdown = "# [Foo]\n[foo]: /url\n> bar\n"

      lhs = "<h1><a href=\"/url\" title=\"\">Foo</a></h1>"
      rhs = "<blockquote><p>bar</p>\n</blockquote>\n"
      ast  = [Floki.parse(lhs), "", Floki.parse(rhs)] |> IO.inspect

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "Link and Image imbrication" do
    @tag :ast
    test "empty (remains such)" do
      markdown = ""
      html = ""
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    @tag :ast
    test "inner is a link, not outer" do
      markdown = "[[text](inner)]outer"
      html = "<p>[<a href=\"inner\">text</a>]outer</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "unless your outer is syntactically a link of course" do
      markdown = "[[text](inner)](outer)"
      html = "<p><a href=\"outer\">[text](inner)</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "escaping does not change that" do
      markdown = "[\\[text\\](inner\\)](outer)"
      html = "<p><a href=\"outer\">[text](inner)</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end

  describe "Links" do

    @tag :ast
    test "no title" do
      markdown = "[link](/uri))\n"
      html = "<p><a href=\"/uri\">link</a>)</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "let's go nowhere" do
      markdown = "[link]()\n"
      html = "<p><a href=\"\">link</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "nowhere in a bottle" do
      markdown = "[link](())\n"
      html = "<p><a href=\"()\">link</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end


  describe "Autolinks" do
    @tag :ast
    test "that was easy" do
      markdown = "<http://foo.bar.baz>\n"
      html = "<p><a href=\"http://foo.bar.baz\">http://foo.bar.baz</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "as was this" do
      markdown = "<irc://foo.bar:2233/baz>\n"
      html = "<p><a href=\"irc://foo.bar:2233/baz\">irc://foo.bar:2233/baz</a></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "good ol' mail" do
      markdown = "<mailto:foo@bar.baz>\n"
      html = "<p><a href=\"mailto:foo@bar.baz\">foo@bar.baz</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "we know what mail is" do
      markdown = "<foo@bar.example.com>\n"
      html = "<p><a href=\"mailto:foo@bar.example.com\">foo@bar.example.com</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "not really a link" do
      markdown = "<>\n"
      html = "<p>&lt;&gt;</p>\n"
      messages = []
      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
