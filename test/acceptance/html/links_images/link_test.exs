defmodule Acceptance.Html.LinkImages.LinkTest do
  use ExUnit.Case, async: true

  use Support.AcceptanceTestCase
  # import Support.GenHtml
  # import Support.Helpers, only: [as_html: 1, as_html: 2]

  describe "Link reference definitions" do
    test "link with title" do
      markdown = "[foo]: /url \"title\"\n\n[foo]\n"
      html     = "<p>\n<a href=\"/url\" title=\"title\">foo</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "assure url encoding is not done here" do
      markdown = "[foo]: /url?url=https%3A%2F%2Fsomewhere \"title\"\n\n[foo]\n"
      html    = "<p>\n<a href=\"/url?url=https%3A%2F%2Fsomewhere\" title=\"title\">foo</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Link and Image imbrication" do
    test "empty (remains such)" do
      markdown = ""
      html = ""
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "inner is a link, not outer" do
      markdown = "[[text](inner)]outer"
      html     = "<p>\n[<a href=\"inner\">text</a>]outer</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Links" do
    test "no title" do
      markdown = "[link](/uri))\n"
      html     = "<p>\n<a href=\"/uri\">link</a>)</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end


  describe "Autolinks" do
    test "that was easy" do
      markdown = "<http://foo.bar.baz>\n"
      html     =  "<p>\n<a href=\"http://foo.bar.baz\">http://foo.bar.baz</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Escapes in text" do
    test "escaped backticks" do 
      markdown = "[hello \\`code\\`](http://some.where)"
      html     = "<p>\n<a href=\"http://some.where\">hello `code`</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
