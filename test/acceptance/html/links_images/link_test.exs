defmodule Acceptance.Html.LinkImages.LinkTest do
  use ExUnit.Case, async: true

  use Support.AcceptanceTestCase
  # import Support.GenHtml
  # import Support.Helpers, only: [as_html: 1, as_html: 2]

  describe "Link reference definitions" do
    test "link with title" do
      markdown = "[foo]: /url \"title\"\n\n[foo]\n"
      html     = link("foo", href: "/url", title: "title")
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "assure url encoding is not done here" do
      markdown = "[foo]: /url?url=https%3A%2F%2Fsomewhere \"title\"\n\n[foo]\n"
      html    = link("foo", href: "/url?url=https%3A%2F%2Fsomewhere", title: "title")
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
      html = para([
        "[", {:a, [href: "inner"], "text"}, "]outer"
      ])
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Links" do
    test "no title" do
      markdown = "[link](/uri))\n"
      html     = para([{:a, [href: "/uri"], "link"}, ")"])
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end


  describe "Autolinks" do
    test "that was easy" do
      markdown = "<http://foo.bar.baz>\n"
      html     = link("http://foo.bar.baz", href: "http://foo.bar.baz")
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Escapes in text" do
    test "escaped backticks" do 
      markdown = "[hello \\`code\\`](http://some.where)"
      html     = para({:a, [href: "http://some.where"], "hello `code`"})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
