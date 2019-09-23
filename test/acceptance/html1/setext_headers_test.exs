defmodule Acceptance.Html1.SetextHeadersTest do
  use ExUnit.Case, async: true
  
  import Support.Html1Helpers
  
  @moduletag :html1
  describe "Base cases" do

    test "Level one" do 
      markdown = "foo\n==="
      html     = construct([:h1, "foo"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "Level two" do 
      markdown = "foo\n---"
      html     = construct([:h2, "foo"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "narrow escape" do
      markdown = "Foo\\\n----\n"
      html     = construct([:h2, "Foo\\"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end

  describe "Combinations" do

    test "levels one and two" do
      markdown = "Foo *bar*\n=========\n\nFoo *bar*\n---------\n"
      html     = construct([
        {:h1, ["Foo ", :em, "bar"]},
        {:h2, ["Foo ", :em, "bar"]}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "and levels two and one" do
      markdown = "Foo\n-------------------------\n\nFoo\n=\n"
      html     = construct([:h2, "Foo", :POP, :h1, "Foo"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end
  # There is no consensus on this one, I prefer to not define the behavior of this unless
  # there is a real use case
  # c.f. http://johnmacfarlane.net/babelmark2/?text=%60Foo%0A----%0A%60%0A%0A%3Ca+title%3D%22a+lot%0A---%0Aof+dashes%22%2F%3E%0A
  #    html = "<h2>`Foo</h2>\n<p>`</p>\n<h2>&lt;a title=&quot;a lot</h2>\n<p>of dashes&quot;/&gt;</p>\n"
  #    markdown = "`Foo\n----\n`\n\n<a title=\"a lot\n---\nof dashes\"/>\n"
  #
  describe "Setext headers with some context" do 

    test "h1 after an unordered list" do 
      markdown = "* foo\n\nbar\n==="
      html     = construct([
        {:ul, {:li, nil, "foo"}}, :h1, "bar"])
      messages = []
      
      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "h2 after an unordered list" do 
      markdown = "* foo\n\nbar\n---"
      html     = construct([
        {:ul, {:li, nil, "foo"}}, :h2, "bar"])
      messages = []
      
      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "h1 after an ordered list and pending text" do 
      markdown = "1. foo\n\nbar\n===\ntext"
      html     = construct([
        {:ol, {:li, nil, "foo"}},
        {:h1, nil, "bar"},
        :p, "text"])
      messages = []
      
      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "h2 between two lists" do 
      markdown = "* foo\n\nbar\n---\n\n1. baz"
      html     = construct([
        {:ul, {:li, nil, "foo"}},
        {:h2, nil, "bar"},
        {:ol, [:li, "baz"]}])
      messages = []
      
      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "h2 between two lists more blank lines" do
      markdown = "1. foo\n\n\nbar\n---\n\n\n* baz"
      html     = construct([
        {:ol, [:li, "foo"]},
        {:h2, nil, "bar"},
        {:ul, [:li, "baz"]}])
      messages = []
      
      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "after a table" do 
    
    test "h2 after a table" do
      markdown = "|a|b|\n|d|e|\nbar\n---"
      html     = construct([
        {:table, [
          {:tr, [ td("a"), td("b") ]},
          {:tr, [ td("d"), td("e") ]}
        ]},
        :h2, "bar"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
