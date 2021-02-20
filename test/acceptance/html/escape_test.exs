defmodule Acceptance.Html.EscapeTest do
  use Support.AcceptanceTestCase

  describe "Escapes" do
    test "dizzy?" do
      markdown = "\\\\!\\\\\""
      html     = "<p>\n\\!\\”</p>\n"
      messages = []

      assert as_html(markdown, smartypants: true) == {:ok, html, messages}
    end

    test "dizzy and not smart :O" do
      markdown = "\\\\!\\\\\""
      html     = "<p>\n\\!\\&quot;</p>\n"
      messages = []

      assert as_html(markdown, smartypants: false) == {:ok, html, messages}
    end

    test "less obviously - escpe the escapes" do
      markdown = "\\\\` code`"
      html     = "<p>\n\\<code class=\"inline\">code</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "line break tag (<br>)" do
      markdown = "hello<br>world"
      html = "<p>\nhello&lt;br&gt;world</p>\n"
      messages = []

      assert as_html(markdown, escape: true) == {:ok, html, messages}
    end
  end

  describe "Escapes Disabled" do
    test "line break tag (<br>)" do
      markdown = "hello<br>world"
      html = "<p>\nhello<br>world</p>\n"
      messages = []

      assert as_html(markdown, escape: false, smartypants: false) == {:ok, html, messages}
    end

    test "semantic line break tag (<br />)" do
      markdown = "hello<br />world"
      html = "<p>\nhello<br />world</p>\n"
      messages = []

      assert as_html(markdown, escape: false) == {:ok, html, messages}
    end

    test "doesn't interfere with smartypants" do
      markdown = "hello<br> 'world'"
      html = "<p>\nhello<br> ‘world’</p>\n"
      messages = []

      assert as_html(markdown, escape: false, smartypants: true) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
