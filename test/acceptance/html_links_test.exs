defmodule Acceptance.HtmlLinksTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1, as_html: 2]

  describe "Autolinks" do
    test "that was easy" do
      markdown = "<http://foo.bar.baz>\n"
      html = "<p><a href=\"http://foo.bar.baz\">http://foo.bar.baz</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "as was this" do
      markdown = "<irc://foo.bar:2233/baz>\n"
      html = "<p><a href=\"irc://foo.bar:2233/baz\">irc://foo.bar:2233/baz</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
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

  describe "Pure links" do
    test "that was easy" do
      markdown = "http://foo.bar.baz"
      html = "<p><a href=\"http://foo.bar.baz\">http://foo.bar.baz</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "a little bit more tricky" do
      markdown = "As seen here http://foo.bar.baz"
      html = ~s{<p>As seen here <a href=\"http://foo.bar.baz\">http://foo.bar.baz</a></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "trickier" do
      markdown = "As seen here http://foo.bar.baz and here https://hello.xxx?yyy=2&z=3"
      html = ~s{<p>As seen here <a href=\"http://foo.bar.baz\">http://foo.bar.baz</a> and here <a href="https://hello.xxx?yyy=2&z=3">https://hello.xxx?yyy=2&amp;z=3</a></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "the trickiest" do
      markdown = "link https://link.org and mail mailto:alpha@beta.io and suffix"
      html = ~s{<p>link <a href="https://link.org">https://link.org</a> and mail <a href="mailto:alpha@beta.io">mailto:alpha@beta.io</a> and suffix</p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end


  describe "Not pure links" do

    test "switched off" do
      markdown = "http://foo.bar.baz"
      html = "<p>http://foo.bar.baz</p>\n"
      messages = []

      assert as_html(markdown, gfm: false) == {:ok, html, messages}
    end

    test "unsupported schema" do
      markdown = "httpx://foo.bar.baz"
      html = "<p>httpx://foo.bar.baz</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
