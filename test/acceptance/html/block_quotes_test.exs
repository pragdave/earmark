defmodule Acceptance.Html.BlockQuotesTest do
  use ExUnit.Case, async: true

  import Support.GenHtml

  describe "with breaks: true" do
    test "acceptance test 490 with breaks" do
      expected = gen({:blockquote, {:p, ["bar", :br, "baz", :br, "foo"]}})
      markdown = "> bar\nbaz\n> foo\n"
      assert Earmark.as_html!(markdown, breaks: true) == expected
    end

    test "acceptance test 582 with breaks" do
      expected = gen({:ul, {:li, ["x", :br, "a", :br, "| A | B |"]}})
      markdown = "* x\n  a\n| A | B |"
      assert Earmark.as_html!(markdown, breaks: true) == expected
    end
  end

  describe "with breaks: false" do
    test "quote my block" do
      markdown = "> Foo"
      html     = gen({:blockquote, {:p, "Foo"}})
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "lists in blockquotes? Coming up Sir" do
      markdown = "> - foo\n- bar\n"
      html     = gen([
        {:blockquote, {:ul, {:li, "foo"}}},
        {:ul, {:li, "bar"}}])
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "indented case" do
      markdown = " > - foo\n- bar\n"
      html     = gen([
        {:blockquote, {:ul, {:li, "foo"}}},
        {:ul, {:li, "bar"}} ])
      messages = []


      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
