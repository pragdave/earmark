defmodule Acceptance.Ast.LinkImages.LinkTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]
  import EarmarkAstDsl

  describe "Link reference definitions" do
    test "link with title" do
      markdown = "[foo]: /url \"title\"\n\n[foo]\n"
      html = "<p><a href=\"/url\" title=\"title\">foo</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end


    test "link with utf8 title" do
      markdown = "[foo]: /url \"Überschrift\"\n\n[foo]\n"
      html = "<p><a href=\"/url\" title=\"Überschrift\">foo</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "this ain't no link" do
      markdown = "[foo]: /url \"title\"\n\n[bar]\n"
      html = "<p>[bar]</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "strange syntaxes exist in Markdown" do
      markdown = "[foo]\n\n[foo]: url\n"
      html = "<p><a href=\"url\" title=\"\">foo</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "sometimes strange text is just strange text" do
      markdown = "[foo]: /url \"title\" ok\n"
      html = "<p>[foo]: /url &quot;title&quot; ok</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, smartypants: false) == {:ok, [ast], messages}
    end

    test "guess how this one is rendered?" do
      markdown = "[foo]: /url \"title\"\n"
      messages = []

      assert as_ast(markdown) == {:ok, [], messages}
    end

    test "or this one, but you might be wrong" do
      markdown = "# [Foo]\n[foo]: /url\n> bar\n"
      lhs = "<h1><a href=\"/url\" title=\"\">Foo</a></h1>"
      rhs = "<blockquote><p>bar</p>\n</blockquote>\n"
      ast  = [parse_html(lhs), parse_html(rhs)]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "Link and Image imbrication" do
    test "empty (remains such)" do
      markdown = ""
      html = ""
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "inner is a link, not outer" do
      markdown = "[[text](inner)]outer"
      html = "<p>[<a href=\"inner\">text</a>]outer</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "unless your outer is syntactically a link of course" do
      markdown = "[[text](inner)](outer)"
      html = "<p><a href=\"outer\">[text](inner)</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "escaping does not change that" do
      markdown = "[\\[text\\](inner\\)](outer)"
      html = "<p><a href=\"outer\">[text](inner)</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end

  describe "Links" do

    test "no title" do
      markdown = "[link](/uri))\n"
      html = "<p><a href=\"/uri\">link</a>)</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "let's go nowhere" do
      markdown = "[link]()\n"
      html = "<p><a href=\"\">link</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "nowhere in a bottle" do
      markdown = "[link](())\n"
      html = "<p><a href=\"()\">link</a></p>\n"
      ast      = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "minimal case" do
      markdown = "([]()"
      html     = "<p>(<a href=\"\"></a></p>\n"
      ast = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "minimal case, ) as suffix" do
      markdown = "([]())"
      html     = "<p>(<a href=\"\"></a>)</p>\n"
      ast = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "normal case" do
      markdown = "([text](link))"
      html     = "<p>(<a href=\"link\">text</a>)</p>\n"
      ast = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "link with nested elements" do
      markdown = "[_foo_ bar](link)"
      html     = "<p><a href=\"link\"><em>foo</em> bar</a></p>\n"
      ast = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "illegal ulrs are not Earmark's responsability (was regtest #51)" do
      markdown = "[<<>>/1](http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#<<>>/1)"
      html     = ~s[<p><a href="http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#<<>>/1">&lt;&lt;&gt;&gt;/1</a></p>]
      ast = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
    
    test "escapes in link's name (was regtest #51)" do
      markdown = "[&expr/1](http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#&expr/1)"
      html     = ~s{<p><a href="http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#&expr/1">&amp;expr/1</a></p>}
      ast = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end


  describe "Autolinks" do
    test "that was easy" do
      markdown = "<http://foo.bar.baz>\n"
      html = "<p><a href=\"http://foo.bar.baz\">http://foo.bar.baz</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "now uri encoding here" do
      markdown = "<http://foo.bar.baz?url=é>\n"
      html = "<p><a href=\"http://foo.bar.baz?url=%C3%A9\">http://foo.bar.baz?url=é</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "now uri encoding with invalid url" do
      markdown = "<http://foo.bar.baz/%{foo}>\n"
      html = "<p><a href=\"http://foo.bar.baz/%{foo}\">http://foo.bar.baz/%{foo}</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "as was this" do
      markdown = "<irc://foo.bar:2233/baz>\n"
      html = "<p><a href=\"irc://foo.bar:2233/baz\">irc://foo.bar:2233/baz</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "good ol' mail" do
      markdown = "<mailto:foo@bar.baz>\n"
      html = "<p><a href=\"mailto:foo@bar.baz\">foo@bar.baz</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "we know what mail is" do
      markdown = "<foo@bar.example.com>\n"
      html = "<p><a href=\"mailto:foo@bar.example.com\">foo@bar.example.com</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "not really a link" do
      markdown = "<>\n"
      html = "<p>&lt;&gt;</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "some special chars inside links" do
    test "parentheses inside the url (was regtest #70)" do
      markdown = ~s{[Wikipedia article on PATH](https://en.wikipedia.org/wiki/PATH_(variable))}
      html     = ~s{<p><a href="https://en.wikipedia.org/wiki/PATH_(variable)">Wikipedia article on PATH</a></p>\n}
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "quotes in text (was regtest #72)" do 
      markdown = ~s{["Earmark"](https://github.com/pragdave/earmark/)}
      html     = ~s{<p><a href="https://github.com/pragdave/earmark/">"Earmark"</a></p>\n}
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "Escapes in text (was regtest #198)" do
    test "escaped backticks" do 
      markdown = "[hello \\`code\\`](http://some.where)"
      ast      = p(tag("a", "hello `code`", href: "http://some.where"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "escaped stars" do
      markdown = "[hello \\*world\\*](http://some.where)"
      html     = ~s{<p><a href="http://some.where">hello *world*</a></p>\n}
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ ast ], messages}
    end

    test "although brackets do not need escapes, we still have to render them correctly" do
      markdown = "[hello \\[world\\]](http://some.where)"
      html     = ~s{<p><a href="http://some.where">hello [world]</a></p>\n}
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
