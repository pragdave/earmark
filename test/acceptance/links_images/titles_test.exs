defmodule Acceptance.LinksImages.TitlesTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1]

  describe "Links with titles" do
    test "two titled links" do
      mark_tmp = "[link](/uri \"title\")"
      markdown = "#{ mark_tmp } #{ mark_tmp }\n"
      html_tmp = "<a href=\"/uri\" title=\"title\">link</a>"
      html = "<p>#{ html_tmp } #{ html_tmp }</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "titled link" do
      markdown = "[link](/uri \"title\")\n"
      html = "<p><a href=\"/uri\" title=\"title\">link</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "titled, followed by untitled" do
      markdown = "[a](a 't') [b](b)"
      html = "<p><a href=\"a\" title=\"t\">a</a> <a href=\"b\">b</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "titled, follwoed by untitled and titled" do

      markdown = "[a](a 't') [b](b) [c](c 't')"
      html = ~s{<p><a href="a" title="t">a</a> <a href="b">b</a> <a href="c" title="t">c</a></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "titled, followed by two untitled" do
      markdown = "[a](a 't') [b](b) [c](c)"
       html = "<p><a href=\"a\" title=\"t\">a</a> <a href=\"b\">b</a> <a href=\"c\">c</a></p>\n"
       messages = []

       assert as_html(markdown) == {:ok, html, messages}
    end

    test "titled, followed by 2 untitled, (quotes interspersed)" do
      markdown = "[a](a 't') [b](b) 'xxx' [c](c)"
       html = "<p><a href=\"a\" title=\"t\">a</a> <a href=\"b\">b</a> ‘xxx’ <a href=\"c\">c</a></p>\n"
       messages = []

       assert as_html(markdown) == {:ok, html, messages}
    end

    test "titled, followed by 2 untitled, (quotes inside parens interspersed)" do
      markdown = "[a](a 't') [b](b) ('xxx') [c](c)"
       html = ~s{<p><a href="a" title="t">a</a> <a href="b">b</a> (‘xxx’) <a href="c">c</a></p>\n}
       messages = []

       assert as_html(markdown) == {:ok, html, messages}
    end


    test "titled link, with deprecated quote mismatch" do
      markdown = "[link](/uri \"title')\n"
      html = "<p><a href=\"/uri%20%22title&#39;\">link</a></p>\n"

      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Images, and links with titles" do
    test "two titled images, different quotes" do
      markdown = ~s{![a](a 't') ![b](b "u")}
      html = ~s{<p><img src="a" alt="a" title="t"/> <img src="b" alt="b" title="u"/></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "two titled images, same quotes" do
      markdown = ~s{![a](a "t") ![b](b "u")}
      html = ~s{<p><img src="a" alt="a" title="t"/> <img src="b" alt="b" title="u"/></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "image and link, same quotes" do
      markdown = ~s{![a](a "t") hello [b](b "u")}
      html = ~s{<p><img src="a" alt="a" title="t"/> hello <a href="b" title="u">b</a></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end 

    test "link and untitled image, and image, same quotes" do
      markdown = ~s{[a](a 't')![between](between)![b](b 'u')}
      html = ~s{<p><a href="a" title="t">a</a><img src="between" alt="between"/><img src="b" alt="b" title="u"/></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

end
