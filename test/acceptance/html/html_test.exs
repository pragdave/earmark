defmodule Acceptance.Html.HtmlBlocksTest do
  use Support.AcceptanceTestCase

  describe "HTML blocks" do
    test "tables are just tables again (or was that mountains?)" do
      markdown = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table>\n\nokay.\n"
      html     = "<table>\n    <tr>      <td>             hi      </td>    </tr></table>\n<p>\nokay.</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "HTML void elements" do
    test "area" do
      markdown = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\">\n**emphasized** text"
      html     =  "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\" />\n<p>\n<strong>emphasized</strong> text</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "HTML and paragraphs" do

    # Related to [#326](https://github.com/pragdave/earmark/issues/326)
    @tag :wip
    test "void elements close para but only at BOL" do
      markdown = "alpha\n <hr />beta"
      html     = "<p>alpha\n <hr />beta</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    @tag :wip
    test "self closing block elements close para, atts and spaces do not matter" do
      markdown = "alpha\n<div class=\"first\"   />beta\ngamma"
      html     = gen([
        {:p, "alpha"},
        {:div, [class: "first"], [""]},
        "beta",
        {:p, "gamma"}])
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    # Related to [#326](https://github.com/pragdave/earmark/issues/326)
    @tag :wip
    test "self closing block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"/>beta"
      html     = "<p>alpha\ngamma<div class=\"fourty two\"/>beta</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    # Related to [#326](https://github.com/pragdave/earmark/issues/326)
    @tag :wip
    test "block elements close para" do
      markdown = "alpha\n<div></div>beta"
      html     = "<p>alpha</p>\n<div></div>beta"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
