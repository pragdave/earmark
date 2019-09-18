defmodule Acceptance.Html1.BlockIalTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

   describe "IAL" do

    test "Not associated" do
      markdown = "{:hello=world}"
      html     = para("{:hello=world}")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "Not associated means verbatim" do
      markdown = "{: hello=world  }"
      html     = para("{: hello=world  }")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "Not associated and incorrect" do
      markdown = "{:hello}"
      html     = para("{:hello}")
      messages = [{:warning, 1, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert to_html1(markdown) == {:error, html, messages}
    end

    test "Associated" do
      markdown = "Before\n{:hello=world}"
      html     = construct([
        {:p, ~s{hello="world"}},
        "Before"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "Associated in between" do
      markdown = "Before\n{:hello=world}\nAfter"
      html     = construct([
        {:p, ~s{hello="world"}},
        "Before",
        :POP,
        :p,
        "After"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "Associated and incorrect" do
      markdown = "Before\n{:hello}"
      html     = para("Before")
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert to_html1(markdown) == {:error, html, messages}
    end

    test "Associated and partly incorrect" do
      markdown = "Before\n{:hello title=world}"
      html     = construct([
        {:p, ~s{title="world"}},
        "Before"])
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert to_html1(markdown) == {:error, html, messages}
    end

    test "Associated and partly incorrect and shortcuts" do
      markdown = "Before\n{:#hello .alpha hello title=world .beta class=\"gamma\" title='class'}"
      html     = construct([
        {:p, "class=\"gamma beta alpha\" id=\"hello\" title=\"class world\""},
        "Before"])
      messages = [{:warning, 2, "Illegal attributes [\"hello\"] ignored in IAL" }]

      assert to_html1(markdown) == {:error, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
