defmodule Acceptance.LinksImages.SimplePureLinksTest do
  use Support.AcceptanceTestCase

  describe "simple pure links not yet enabled" do
    test "regression" do
      markdown = "<https://github.com/pragdave/earmark>"
      html = "<p><a href=\"https://github.com/pragdave/earmark\">https://github.com/pragdave/earmark</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "issue deprecation warning" do
      markdown = "https://github.com/pragdave/earmark"
      html = "<p>https://github.com/pragdave/earmark</p>\n"
      message = """
      The string "https://github.com/pragdave/earmark" will be rendered as a link if the option `pure_links` is enabled.
      This will be the case by default in version 1.4.
      Disable the option explicitly with `false` to avoid this message.
      """
      messages = [{:deprecation, 1, String.trim(message)}]

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "issue deprecation warning surpressed" do
      markdown = "https://github.com/pragdave/earmark"
      html = "<p>https://github.com/pragdave/earmark</p>\n"
      messages = []

      assert as_html(markdown, pure_links: false) == {:ok, html, messages}
    end

    test "explicitly enabled" do
      markdown = "https://github.com/pragdave/earmark"
      html = "<p><a href=\"https://github.com/pragdave/earmark\">https://github.com/pragdave/earmark</a></p>\n"
      messages = []

      assert as_html(markdown, pure_links: true) == {:ok, html, messages}
    end
  end

  describe "enabled pure links" do
    test "two in a row" do
      markdown = "https://github.com/pragdave/earmark https://github.com/RobertDober/extractly"
      html = "<p><a href=\"https://github.com/pragdave/earmark\">https://github.com/pragdave/earmark</a> <a href=\"https://github.com/RobertDober/extractly\">https://github.com/RobertDober/extractly</a></p>\n"
      messages = []

      assert as_html(markdown, pure_links: true) == {:ok, html, messages}
    end

    test "more text" do
      markdown = "Header http://wikipedia.org in between <http://hex.pm> Trailer"
      html = "<p>Header <a href=\"http://wikipedia.org\">http://wikipedia.org</a> in between <a href=\"http://hex.pm\">http://hex.pm</a> Trailer</p>\n"
      messages = []
      
      assert as_html(markdown, pure_links: true) == {:ok, html, messages}
    end

    test "more links" do
      markdown = "[Erlang](https://erlang.org) & https://elixirforum.com"
      html = "<p><a href=\"https://erlang.org\">Erlang</a> &amp; <a href=\"https://elixirforum.com\">https://elixirforum.com</a></p>\n"
      messages = []

      assert as_html(markdown, pure_links: true) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
