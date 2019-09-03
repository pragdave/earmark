defmodule Acceptance.Ast.LinksImages.SimplePureLinksTest do
  use Support.AcceptanceTestCase
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]

  @moduletag :ast

  describe "simple pure links not yet enabled" do
    test "regression" do
      markdown = "<https://github.com/pragdave/earmark>"
      html = "<p><a href=\"https://github.com/pragdave/earmark\">https://github.com/pragdave/earmark</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end


    test "issue deprecation warning surpressed" do
      markdown = "https://github.com/pragdave/earmark"
      html = "<p>https://github.com/pragdave/earmark</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, pure_links: false) == {:ok, [ast], messages}
    end

    test "explicitly enabled" do
      markdown = "https://github.com/pragdave/earmark"
      html = "<p><a href=\"https://github.com/pragdave/earmark\">https://github.com/pragdave/earmark</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, pure_links: true) == {:ok, [ast], messages}
    end
  end

  describe "enabled pure links" do
    test "two in a row" do
      markdown = "https://github.com/pragdave/earmark https://github.com/RobertDober/extractly"
      html = "<p><a href=\"https://github.com/pragdave/earmark\">https://github.com/pragdave/earmark</a> <a href=\"https://github.com/RobertDober/extractly\">https://github.com/RobertDober/extractly</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, pure_links: true) == {:ok, [ast], messages}
    end

    test "more text" do
      markdown = "Header http://wikipedia.org in between <http://hex.pm> Trailer"
      html = "<p>Header <a href=\"http://wikipedia.org\">http://wikipedia.org</a> in between <a href=\"http://hex.pm\">http://hex.pm</a> Trailer</p>\n"
      ast      = parse_html(html)
      messages = []
      
      assert as_ast(markdown, pure_links: true) == {:ok, [ast], messages}
    end

    test "more links" do
      markdown = "[Erlang](https://erlang.org) & https://elixirforum.com"
      html = "<p><a href=\"https://erlang.org\">Erlang</a> &amp; <a href=\"https://elixirforum.com\">https://elixirforum.com</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, pure_links: true) == {:ok, [ast], messages}
    end

    test "be aware of the double up" do
      markdown = "[https://erlang.org](https://erlang.org)"
      html = "<p><a href=\"https://erlang.org\">https://erlang.org</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, pure_links: true) == {:ok, [ast], messages}
    end

    test "inner pure_links disabling does not leak out" do
      markdown = "[https://erlang.org](https://erlang.org) https://elixir.lang"
      html = "<p><a href=\"https://erlang.org\">https://erlang.org</a> <a href=\"https://elixir.lang\">https://elixir.lang</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, pure_links: true) == {:ok, [ast], messages}

    end
  end
end

# SPDX-License-Identifier: Apache-2.0
