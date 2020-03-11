defmodule Acceptance.Html.InlineCodeTest do
  use Support.AcceptanceTestCase
  describe "Inline Code" do
    test "plain simple" do
      markdown = "`foo`\n"
      html = "<p>\n<code class=\"inline\">foo</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Inline Code with escapes" do

    test "with company" do
      markdown = "`hello \\\\ world`"
      html = "<p>\n<code class=\"inline\">hello \\\\ world</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end

  describe "whitespace treatment" do
    test "squashing" do
      markdown = "`alpha   beta`"
      html = "<p>\n<code class=\"inline\">alpha beta</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "remove at start" do
      markdown = "`  alpha beta`"
      html = "<p>\n<code class=\"inline\">alpha beta</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end


    test "remove and squash newlines too" do
      markdown = "`\n  alpha  \n\n beta `"
      html = "<p>\n<code class=\"inline\">alpha beta</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
