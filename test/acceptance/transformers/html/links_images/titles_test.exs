defmodule Acceptance.Transformers.Html.LinksImages.TitlesTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Links with titles" do
    test "two titled links" do
      mark_tmp = "[link](/uri \"title\")"
      markdown = "#{ mark_tmp } #{ mark_tmp }\n"
      html_part = [
        {:a, "href=\"/uri\" title=\"title\""},
        "link",
        :POP
      ]
      html = para(html_part ++ html_part)
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "titled link" do
      markdown = "[link](/uri \"title\")\n"
      html = para([
        {:a, "href=\"/uri\" title=\"title\""},
        "link"
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "titled, followed by untitled" do
      markdown = "[a](a 't') [b](b)"
      html = para([
        {:a, "href=\"a\" title=\"t\""},
        "a",
        :POP,
        {:a, "href=\"b\""},
        "b" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "titled, followed by untitled and titled" do
      markdown = "[a](a 't') [b](b) [c](c 't')"
      html = para([
        {:a, "href=\"a\" title=\"t\""},
        "a",
        :POP,
        {:a, "href=\"b\""},
        "b",
        :POP,
        {:a, "href=\"c\" title=\"t\""},
        "c" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "titled, followed by two untitled" do
      markdown = "[a](a 't') [b](b) [c](c)"
       html = para([
        {:a, "href=\"a\" title=\"t\""},
        "a",
        :POP,
        {:a, "href=\"b\""},
        "b",
        :POP,
        {:a, "href=\"c\""},
        "c" ])
       messages = []

       assert to_html1(markdown) == {:ok, html, messages}
    end

    test "titled, followed by 2 untitled, (quotes interspersed), smartypants are not the default" do
      markdown = "[a](a 't') [b](b) 'xxx' [c](c)"
       html = para([
        {:a, "href=\"a\" title=\"t\""},
        "a",
        :POP,
        {:a, "href=\"b\""},
        "b",
        :POP,
        " &#39;xxx&#39; ",
        {:a, "href=\"c\""},
        "c" ])
       messages = []

       assert to_html1(markdown) == {:ok, html, messages}
    end

    test "titled, followed by 2 untitled, (quotes interspersed), smartypants enabled" do
      markdown = "[a](a 't') [b](b) 'xxx' [c](c)"
       html = para([
        {:a, "href=\"a\" title=\"t\""},
        "a",
        :POP,
        {:a, "href=\"b\""},
        "b",
        :POP,
        " ‘xxx’ ",
        {:a, "href=\"c\""},
        "c" ])
       messages = []

       assert to_html1(markdown, %Earmark.Options{}) == {:ok, html, messages}
    end

    test "titled, followed by 2 untitled, (quotes inside parens interspersed)" do
      markdown = "[a](a 't') [b](b) ('xxx') [c](c)"
       html = para([
         {:a, ~s{href="a" title="t"}},
         "a",
         :POP,
         {:a, ~s{href="b"}},
         "b",
         :POP,
         " (‘xxx’) ",
         {:a, ~s{href="c"}},
         "c" ])
       messages = []

       assert to_html1(markdown, smartypants: true) == {:ok, html, messages}
    end


    test "titled link, with deprecated quote mismatch" do
      markdown = "[link](/uri \"title')\n"
      html = para( {:a, ~s{href="/uri \"title'"}, "link"} )
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "Images, and links with titles" do
    test "two titled images, different quotes" do
      markdown = ~s{![a](a 't') ![b](b "u")}
      html = para([
        {:img, ~s{src="a" alt="a" title="t"}},
        {:img, ~s{src="b" alt="b" title="u"}}])

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "two titled images, same quotes" do
      markdown = ~s{![a](a "t") ![b](b "u")}
      html = para([
        {:img, ~s{src="a" alt="a" title="t"}},
        {:img, ~s{src="b" alt="b" title="u"}}])

        
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "image and link, same quotes" do
      markdown = ~s{![a](a "t") hello [b](b "u")}
      html = para([
        {:img, ~s{src="a" alt="a" title="t"}},
        " hello ",
        {:a, ~s{href="b" title="u"}}, 
        "b"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end 

    test "link and untitled image, and image, same quotes" do
      markdown = ~s{[a](a 't')![between](between)![b](b 'u')}
      html = para([
        {:a, ~s{href="a" title="t"}},
        "a",
        :POP,
        {:img, ~s{src="between" alt="between"}},
        {:img, ~s{src="b" alt="b" title="u"}} ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

end
