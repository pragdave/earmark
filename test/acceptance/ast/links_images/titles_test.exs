defmodule Acceptance.Ast.LinksImages.TitlesTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import EarmarkAstDsl

  describe "Links with titles" do
    test "two titled links" do
      mark_tmp = "[link](/uri \"title\")"
      markdown = "#{ mark_tmp } #{ mark_tmp }\n"
      ast      = p([
        tag("a", "link", href: "/uri", title: "title"),
        tag("a", "link", href: "/uri", title: "title") ])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "titled link" do
      markdown = "[link](/uri \"title\")\n"
      html = "<p><a href=\"/uri\" title=\"title\">link</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "titled, followed by untitled" do
      markdown = "[a](a 't') [b](b)"
      ast      = p([
        tag("a", "a", href: "a", title: "t"),
        tag("a", "b", href: "b")])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "titled, followed by untitled and titled" do
      markdown = "[a](a 't') [b](b) [c](c 't')"
      ast      = p([
        tag("a", "a", href: "a", title: "t"),
        tag("a", "b", href: "b"),
        tag("a", "c", href: "c", title: "t")])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "titled, followed by two untitled" do
      markdown = "[a](a 't') [b](b) [c](c)"
      ast      = p([
        tag("a", "a", href: "a", title: "t"),
        tag("a", "b", href: "b"),
        tag("a", "c", href: "c")])
       messages = []

       assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "titled, followed by 2 untitled, (quotes interspersed)" do
      markdown = "[a](a 't') [b](b) 'xxx' [c](c)"
      ast      = p([
        tag("a", "a", href: "a", title: "t"),
        tag("a", "b", href: "b"),
        " 'xxx' ",
        tag("a", "c", href: "c")])
       messages = []

       assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "titled, followed by 2 untitled, (quotes inside parens interspersed)" do
      markdown = "[a](a 't') [b](b) ('xxx') [c](c)"
       ast      = p([
        tag("a", "a", href: "a", title: "t"),
        tag("a", "b", href: "b"),
        " ('xxx') ",
        tag("a", "c", href: "c")])
       messages = []

       assert as_ast(markdown) == {:ok, [ast], messages}
    end


    test "titled link, with deprecated quote mismatch" do
      markdown = "[link](/uri \"title')\n"
      ast = p(tag("a", "link", href: "/uri \"title'"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "Images, and links with titles" do
    test "two titled images, different quotes" do
      markdown = ~s{![a](a 't') ![b](b "u")}
      ast      = p([
        void_tag("img", src: "a", alt: "a", title: "t"),
        void_tag("img", src: "b", alt: "b", title: "u")])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "two titled images, same quotes" do
      markdown = ~s{![a](a "t") ![b](b "u")}
      ast      = p([
        void_tag("img", src: "a", alt: "a", title: "t"),
        void_tag("img", src: "b", alt: "b", title: "u")])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "image and link, same quotes" do
      markdown = ~s{![a](a "t") hello [b](b "u")}
      html = ~s{<p><img src="a" alt="a" title="t"/> hello <a href="b" title="u">b</a></p>\n}
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end 

    test "link and untitled image, and image, same quotes" do
      markdown = ~s{[a](a 't')![between](between)![b](b 'u')}
      html = ~s{<p><a href="a" title="t">a</a><img src="between" alt="between"/><img src="b" alt="b" title="u"/></p>\n}
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "titleoids after link (was regtest # 244)" do
    test "title must not come from outside -- double / double" do
      markdown = "The [Foo](/dash \"foo\") page (in \"bar\")\n"
      html     = "<p>The <a href=\"/dash\" title=\"foo\">Foo</a> page (in \"bar\")</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "title must not come from outside -- double / single" do
      markdown = "The [Foo](/dash \"foo\") page (in 'bar')\n"
      html     = "<p>The <a href=\"/dash\" title=\"foo\">Foo</a> page (in 'bar')</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "title must not come from outside -- single / double" do
      markdown = "The [Foo](/dash 'foo') page (in \"bar\")\n"
      html     = "<p>The <a href=\"/dash\" title=\"foo\">Foo</a> page (in \"bar\")</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "title must not come from outside -- single / single " do
      markdown = "The [Foo](/dash 'foo') page (in 'bar')\n"
      html     = "<p>The <a href=\"/dash\" title=\"foo\">Foo</a> page (in 'bar')</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end
