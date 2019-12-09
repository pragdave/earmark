defmodule Acceptance.Transformers.Html.ListIndentTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1
  describe "different levels of indent" do

    test "ordered two levels, indented by two" do
      markdown = "1. One\n  2. two"
      html     = construct(
        {:ol, nil,
          {:li, nil, [
            {:p, nil, "One"},
            {:ol, ~s{start="2"},
              {:li, nil, "two"}}]}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "mixed two levels (by 2)" do
      markdown = "1. One\n  - two\n  - three"
      html     = construct(
        {:ol, nil,
          {:li, nil, [
            {:p, nil, "One"},
            {:ul, nil, [ 
               {:li, nil, "two"},
               {:li, nil, "three"}]}]}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "mixed two levels (by 4)" do
      markdown = "1. One\n    - two\n    - three"
      html     = construct(
        {:ol, nil, 
           {:li, nil, [
             {:p, nil, "One"},
             {:ul, nil, [
               {:li, nil, "two"},
               {:li, nil, "three"}]}]}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "2 level correct pop up" do
      markdown = "- 1\n  - 1.1\n    - 1.1.1\n  - 1.2"
      html     = construct(
        {:ul, nil,
           {:li, nil, [
              {:p, nil, "1"},
              {:ul, nil, [
                {:li, nil, [
                  {:p, nil, "1.1"},
                  {:ul, nil, {:li, nil, "1.1.1"}}]},
                {:li, nil, "1.2"}]}]}})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "mixed level correct pop up" do
      markdown = "- 1\n  - 1.1\n      - 1.1.1\n  - 1.2"
      html     = construct(
        {:ul, nil,
           {:li, nil, [
              {:p, nil, "1"},
              {:ul, nil, [
                {:li, nil, [
                  {:p, nil, "1.1"},
                  {:ul, nil, {:li, nil, "1.1.1"}}]},
                {:li, nil, "1.2"}]}]}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "4 level correct pop up" do
      markdown = "- 1\n    - 1.1\n        - 1.1.1\n    - 1.2"
      html     = construct(
        {:ul, nil,
           {:li, nil, [
              {:p, nil, "1"},
              {:ul, nil, [
                {:li, nil, [
                  {:p, nil, "1.1"},
                  {:ul, nil, {:li, nil, "1.1.1"}}]},
                {:li, nil, "1.2"}]}]}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
