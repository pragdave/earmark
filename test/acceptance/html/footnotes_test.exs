defmodule Acceptance.Html.FootnotesTest do
  use Support.AcceptanceTestCase

  describe "Footnotes" do
    test "without errors" do
      markdown = "foo[^1] again\n\n[^1]: bar baz"

      {:ok, html, []} = as_html(markdown, footnotes: true)
      {:ok, [
        {"p", [], 
          ["\nfoo", 
            {"a", link_atts, ["1"]},
          " again"]},
        {"div", [{"class", "footnotes"}], footnote}
      ]} = Floki.parse_document(html)

      assert Enum.sort(link_atts) == [
        {"class", "footnote"},
        {"href", "#fn:1"},
        {"id", "fnref:1"},
        {"title", "see footnote"}
      ]

      [
        {"hr", [], []},
        {"ol", [],
          [
            {"li", [{"id", "fn:1"}],
              [
                {"a", backlink_atts, ["↩"]},
                {"p", [], ["\nbar baz      "]}
              ]}
          ]}
      ] = footnote

      assert Enum.sort(backlink_atts) == [
        {"class", "reversefootnote"},
        {"href", "#fnref:1"},
        {"title", "return to article"},
      ]
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
