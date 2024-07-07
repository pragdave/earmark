defmodule Test.Acceptance.Html.Instrumentation.SpecificInstrumentationTest do
  use Support.AcceptanceTestCase
  import Earmark.AstTools

  describe "register postprocessor for <a> only" do
    test "this makes it simpler to preprocess links" do
      markdown = "[foo]: /url \"title\"\n\n[foo]\n"
      html = "<p>\n<a href=\"/url\" target=\"_blank\" title=\"title\">foo</a></p>\n"
      messages = []

      assert as_html(markdown,
               registered_processors: {"a", &merge_atts_in_node(&1, target: "_blank")}
             ) == {:ok, html, messages}
    end

    test "and only links" do
      markdown = "This is a [link](to_a_url)\n- right?"

      html =
        "<p>\nThis is a <a href=\"to_a_url\" target=\"_blank\">link</a></p>\n<ul>\n  <li>\nright?  </li>\n</ul>\n"

      messages = []

      assert as_html(markdown,
               registered_processors: {"a", &merge_atts_in_node(&1, target: "_blank")}
             ) == {:ok, html, messages}
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
