defmodule Acceptance.Html1.TableTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1
  
  describe "complex rendering inside tables:" do 

    test "simple table" do 
      markdown = "|a|b|\n|d|e|"
      html     = construct(
        {:table, [
            {:tr, [ td("a"), td("b") ]},
            {:tr, [ td("d"), td("e") ]}]})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "table with link with inline ial, no errors" do 
      
      markdown = "|a|b|c|\n|d|e|[link](url){:target=blank}|"
      html     = construct(
        {:table, [
            {:tr, [ td("a"), td("b"), td("c") ]},
            {:tr, [ 
              td("d"),
              td("e"),
              td({:a, ~s{href="url" target="blank"}, "link"})
            ]}]})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "table with link with inline ial, errors" do 
      
      markdown = "|a|b|c|\n|d|e|[link](url){:target=blank xxx}|"
      html     = construct(
        {:table, [
            {:tr, [ td("a"), td("b"), td("c") ]},
            {:tr, [ 
              td("d"),
              td("e"),
              td({:a, ~s{href="url" target="blank"}, "link"})
            ]}]})
      messages = [{:warning, 2, "Illegal attributes [\"xxx\"] ignored in IAL"}]

      assert to_html1(markdown) == {:error, html, messages}
    end

    test "table with header" do
      markdown = "|alpha|beta|\n|-|-:|\n|1|2|"
      html     = construct(
        {:table, [
            {:thead, 
              {:tr, [ th("alpha"), th("beta", :right) ] }},
            {:tr, [ td("1"), td("2", :right) ]}]})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "table with header inside context" do
      markdown = "before\n\n|alpha|beta|\n|-|-:|\n|1|2|\nafter"
      html     = construct([
        :p, "before", :POP,
        {:table, [
          {:thead, 
            {:tr, [ th("alpha"), th("beta", :right) ] }},
            {:tr, [ td("1"), td("2", :right) ]}]},
        :p, "after"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "Tables and IAL" do
    test "as mentioned above" do
      markdown = "|a|b|\n|d|e|\n{:#the-table}"
      html     = construct(
        {:table, ~s{id="the-table"}, [
            {:tr, [ td("a"), td("b") ]},
            {:tr, [ td("d"), td("e") ]}]})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
