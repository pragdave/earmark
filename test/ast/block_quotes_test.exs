defmodule Acceptance.BlockQuotesTest do
  use ExUnit.Case

  # describe "Block Quotes" do
    test "quote my block" do
      markdown = "> Foo"
      # html     = "<blockquote><p>Foo</p>\n</blockquote>\n"
      ast = {"blockquote", [], [{"p", [], ["Foo"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "and block my quotes" do
      markdown = "> # Foo\n> bar\n> baz\n"
      # html     = "<blockquote><h1>Foo</h1>\n<p>bar\nbaz</p>\n</blockquote>\n"
      ast = {"blockquote", [], [{"h1", [], ["Foo"]}, {"p", [], ["barbaz"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "linient we are" do
      markdown = "> bar\nbaz\n> foo\n"
      # html     = "<blockquote><p>bar\nbaz\nfoo</p>\n</blockquote>\n"
      ast = {"blockquote", [], [{"p", [], ["barbazfoo"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "lists in blockquotes? Coming up Sir" do
      markdown = "> - foo\n- bar\n"
      # html     = "<blockquote><ul>\n<li>foo\n</li>\n</ul>\n</blockquote>\n<ul>\n<li>bar\n</li>\n</ul>\n"
      ast = [{"blockquote", [], [{"ul", [], [{"li", [], ["foo"]}]}]}, {"ul", [], [{"li", [], ["bar"]}]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

  # end
end
