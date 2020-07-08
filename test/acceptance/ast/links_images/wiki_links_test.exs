defmodule Acceptance.Ast.LinkImages.WikiLinksTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  describe "Wiki links" do
    test "basic wiki-style link" do
      markdown = "[[page]]"
      html = "<p><a class=\"wikilink\" href=\"page\">page</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "misleading non-wiki link" do
      markdown = "[[page]](actual_link)"
      html = "<p><a href=\"actual_link\">[page]</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "alternate text" do
      markdown = "[[page | My Label]]"
      html = "<p><a class=\"wikilink\" href=\"page\">My Label</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "illegal urls are not Earmark's responsability" do
      markdown = "[[A long & complex title]]"
      html = "<p><a class=\"wikilink\" href=\"A long & complex title\">A long &amp; complex title</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end
