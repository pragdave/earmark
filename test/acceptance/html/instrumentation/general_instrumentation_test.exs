defmodule Test.Acceptance.Html.Instrumentation.GeneralInstrumentationTest do
  use Support.AcceptanceTestCase
  import Earmark.AstTools

  describe "Application to links" do
    test "one link" do
      markdown = "[foo]: /url \"title\"\n\n[foo]\n"
      html = "<p>\n<a href=\"/url\" target=\"_blank\" title=\"title\">foo</a></p>\n"
      messages = []

      assert as_html(markdown, postprocessor: &_add_target/1) == {:ok, html, messages}
    end

    test "selective because of the postprocessors's design" do
      markdown = "This is a [link](to_a_url)\n- right?"

      html =
        "<p>\nThis is a <a href=\"to_a_url\" target=\"_blank\">link</a></p>\n<ul>\n  <li>\nright?  </li>\n</ul>\n"

      messages = []

      assert as_html(markdown, postprocessor: &_add_target/1) == {:ok, html, messages}
    end
  end

  describe "general application" do
    test "add class to all but paras" do
      markdown = "Para\n- A list"

      html =
        "<p>\nPara</p>\n<ul class=\"special\">\n  <li class=\"special\">\nA list  </li>\n</ul>\n"

      messages = []

      assert as_html(markdown, postprocessor: &_add_class(&1, "special"), ignore_strings: true) ==
               {:ok, html, messages}
    end
  end

  defp _add_class(node, class)
  defp _add_class({"p", _, _, _} = node, _), do: node
  defp _add_class(node, class), do: merge_atts_in_node(node, class: class)

  defp _add_target(ast_node)

  defp _add_target({"a", _atts, _content, _meta} = node),
    do: merge_atts_in_node(node, target: "_blank")

  defp _add_target(anything), do: anything
end

# SPDX-License-Identifier: Apache-2.0
