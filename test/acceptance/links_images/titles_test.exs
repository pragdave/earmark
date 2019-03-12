defmodule Acceptance.LinksImages.TitlesTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1, as_html: 2]

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
      html = "<p><a href=\"a\" title=\"t&#39;) [b](b) [c](c &#39;t\">a</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    # # KO

    test "titled, followed by two untitled" do
      markdown = "[a](a 't') [b](b) [c](c)"
      # {:ok,
       html = "<p><a href=\"a\" title=\"t\">a</a> <a href=\"b\">b</a> <a href=\"c\">c</a></p>\n"
       messages = []

       assert as_html(markdown) == {:ok, html, messages}
    end
    #  []}
    # # OK

    test "titled, followed by 2 untitled, (quotes interspersed)" do
      markdown = "[a](a 't') [b](b) 'xxx' [c](c)"
      # {:ok,
       html = "<p><a href=\"a\" title=\"t\">a</a> <a href=\"b\">b</a> ‘xxx’ <a href=\"c\">c</a></p>\n"
       messages = []

       assert as_html(markdown) == {:ok, html, messages}
    end
    #  []}
    # # OK

    test "titled, followed by 2 untitled, (quotes inside parens interspersed)" do
      markdown = "[a](a 't') [b](b) ('xxx') [c](c)"
      # {:ok,
       html = "<p><a href=\"a\" title=\"t&#39;) [b](b) (&#39;xxx\">a</a> <a href=\"c\">c</a></p>\n"
       messages = []

       assert as_html(markdown) == {:ok, html, messages}
    end
    #  []}
    # # KO


    test "titled link, with deprecated quote mismatch" do
      markdown = "[link](/uri \"title')\n"
      html = "<p><a href=\"/uri%20%22title&#39;\">link</a></p>\n"

      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end
