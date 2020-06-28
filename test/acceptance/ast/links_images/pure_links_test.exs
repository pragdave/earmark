defmodule Acceptance.Ast.LinksImages.PureLinksTest do
  use Support.AcceptanceTestCase
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]
  import EarmarkAstDsl

  describe "simple pure links not yet enabled" do
    test "issue deprecation warning surpressed" do
      markdown = "https://github.com/pragdave/earmark"
      html = "<p>https://github.com/pragdave/earmark</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, pure_links: false) == {:ok, [ast], messages}
    end

  end

  describe "enabled pure links" do
    test "two in a row" do
      markdown = "https://github.com/pragdave/earmark https://github.com/RobertDober/extractly"
      html = "<p><a href=\"https://github.com/pragdave/earmark\">https://github.com/pragdave/earmark</a> <a href=\"https://github.com/RobertDober/extractly\">https://github.com/RobertDober/extractly</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "more text" do
      markdown = "Header http://wikipedia.org in between <http://hex.pm> Trailer"
      html = "<p>Header <a href=\"http://wikipedia.org\">http://wikipedia.org</a> in between <a href=\"http://hex.pm\">http://hex.pm</a> Trailer</p>\n"
      ast      = parse_html(html)
      messages = []
      
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "more links" do
      markdown = "[Erlang](https://erlang.org) & https://elixirforum.com"
      html = "<p><a href=\"https://erlang.org\">Erlang</a> &amp; <a href=\"https://elixirforum.com\">https://elixirforum.com</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "be aware of the double up" do
      markdown = "[https://erlang.org](https://erlang.org)"
      html = "<p><a href=\"https://erlang.org\">https://erlang.org</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "correct mix" do
      markdown = "[https://erlang.org](https://erlang.org) https://elixir.lang"
      html = "<p><a href=\"https://erlang.org\">https://erlang.org</a> <a href=\"https://elixir.lang\">https://elixir.lang</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}

    end
  end

  describe "parenthesis (was: regression #342)" do
    test "simplest error case" do
      markdown = "http://my.org/robert(is_best)"
      ast      = p(tag("a", ["http://my.org/robert(is_best)"],[{"href", "http://my.org/robert(is_best)"}]))
      messages = []
      
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "imbrication" do
      markdown = "(http://my.org/robert(is_best)"
      ast      = p(["(", tag("a", ["http://my.org/robert(is_best"],[{"href", "http://my.org/robert(is_best"}]), ")"])
      messages = []
      
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "enough imbrication" do
      markdown = "(http://my.org/robert(is_best))"
      ast      = p(["(", tag("a", ["http://my.org/robert(is_best)"],[{"href", "http://my.org/robert(is_best)"}]), ")"])
      messages = []
      
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "most imbricated" do
      markdown = "((http://my.org/robert(c'estça)))"
      ast      = p(["((", tag("a", ["http://my.org/robert(c'estça)"],[{"href", "http://my.org/robert(c'est%C3%A7a)"}]), "))"])
      messages = []
      
      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "recoding is cool" do
      markdown = "((http://github.com(c'est%C3%A7a)))"
      ast      = p(["((", tag("a", ["http://github.com(c'estça)"], [{"href", "http://github.com(c'est%C3%A7a)"}]), "))"])
      messages = []
      
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "more acceptable characters (was: regression #350)" do
    test "a Github link" do
      markdown = "https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}"
      ast      = p(tag("a", ["https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}"], [{"href", "https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}"}]))
      messages = []
      
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
    test "a recursive link" do
      markdown = "https://babelmark.github.io/?text=*+List+item%0A%0A++Text%0A%0A++++*+List+item%0A%0A++Text%0A%0A++++++https%3A%2F%2Fmydomain.org%2Fuser_or_team%2Frepo_name%2Fblob%2Fmaster%2F%25%7Bpath%7D%23L%25%7Bline%7D%0"
      ast      = p(tag("a", markdown, [{"href", markdown}]))
      messages = []
      
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
    
  end

end

# SPDX-License-Identifier: Apache-2.0
