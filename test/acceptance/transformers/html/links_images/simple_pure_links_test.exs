defmodule Acceptance.Transformers.Html.LinksImages.SimplePureLinksTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "simple pure links not yet enabled" do
    test "old behavior" do
      markdown = "https://github.com/pragdave/earmark"
      html = construct([
        :p,
        "https://github.com/pragdave/earmark"
      ])
      messages = []

      assert to_html1(markdown, pure_links: false) == {:ok, html, messages}
    end

    test "explicitly enabled" do
      markdown = "https://github.com/pragdave/earmark"
      html = construct([
        :p,
        {:a, "href=\"https://github.com/pragdave/earmark\""},
        "https://github.com/pragdave/earmark",
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "enabled pure links" do
    test "two in a row" do
      markdown = "https://github.com/pragdave/earmark https://github.com/RobertDober/extractly"
      html = construct([
        :p,
        {:a, "href=\"https://github.com/pragdave/earmark\""},
        "https://github.com/pragdave/earmark",
        :POP,
        {:a, "href=\"https://github.com/RobertDober/extractly\""},
        "https://github.com/RobertDober/extractly",
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "more text" do
      markdown = "Header http://wikipedia.org in between <http://hex.pm> Trailer"
      html = construct([
        :p,
        "Header ",
        {:a, "href=\"http://wikipedia.org\""},
        "http://wikipedia.org",
        :POP,
        " in between ",
        {:a, "href=\"http://hex.pm\""},
        "http://hex.pm",
        :POP,
        " Trailer" ])
      messages = []
      
      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "more links" do
      markdown = "[Erlang](https://erlang.org) & https://elixirforum.com"

      html = construct([
        :p,
        {:a, "href=\"https://erlang.org\""},
        "Erlang",
        :POP,
        " &amp; ",
        {:a, "href=\"https://elixirforum.com\""},
        "https://elixirforum.com" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "be aware of the double up" do
      markdown = "[https://erlang.org](https://erlang.org)"
      html = construct([
        :p,
        {:a, "href=\"https://erlang.org\""},
        "https://erlang.org" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "inner pure_links disabling does not leak out" do
      markdown = "[https://erlang.org](https://erlang.org) https://elixir.lang"
      html = construct([
        :p,
        {:a, "href=\"https://erlang.org\""},
        "https://erlang.org",
        :POP,
        {:a, "href=\"https://elixir.lang\""},
        "https://elixir.lang",
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}

    end
  end
end

# SPDX-License-Identifier: Apache-2.0
