defmodule Acceptance.Ast.HtmlBlocksTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_html: 1]

  # describe "HTML blocks" do
    test "tables are just tables again (or was that mountains?)" do
      markdown = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table>\n\nokay.\n"
      html     = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table><p>okay.</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "div (ine?)" do
      markdown = "<div>\n  *hello*\n         <foo><a>\n</div>\n"
      html     = "<div>\n  *hello*\n         <foo><a>\n</div>"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "we are leaving html alone" do
      markdown = "<div>\n*Emphasized* text.\n</div>"
      html     = "<div>\n*Emphasized* text.\n</div>"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  # end

  # describe "HTML void elements" do
    test "area" do
      markdown = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\">\n**emphasized** text"
      html     = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\"><p><strong>emphasized</strong> text</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "we are outside the void now (lucky us)" do
      markdown = "<br>\n**emphasized** text"
      html     = "<br><p><strong>emphasized</strong> text</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "high regards???" do
      markdown = "<hr>\n**emphasized** text"
      html     = "<hr><p><strong>emphasized</strong> text</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "img (a punless test)" do
      markdown = "<img src=\"hello\">\n**emphasized** text"
      html     = "<img src=\"hello\"><p><strong>emphasized</strong> text</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "not everybode knows this one (hint: take a break)" do
      markdown = "<wbr>\n**emphasized** text"
      html = "<wbr><p><strong>emphasized</strong> text</p>\n"
      messages = []
      assert as_html(markdown) == {:ok, html, messages}
    end
  # end

  # describe "HTML and paragraphs" do
    test "void elements close para" do
      markdown = "alpha\n<hr>beta"
      html     = "<p>alpha</p>\n<hr>beta"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "void elements close para but only at BOL" do
      markdown = "alpha\n <hr>beta"
      html     = "<p>alpha\n <hr>beta</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para" do
      markdown = "alpha\n<div/>beta"
      html     = "<p>alpha</p>\n<div/>beta"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"/>beta"
      html     = "<p>alpha</p>\n<div class=\"first\"/>beta"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para, atts and spaces do not matter" do
      markdown = "alpha\n<div class=\"first\"   />beta\ngamma"
      html     = "<p>alpha</p>\n<div class=\"first\"   />beta<p>gamma</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para but only at BOL" do
      markdown = "alpha\n <div/>beta"
      html     = "<p>alpha\n <div/>beta</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"/>beta"
      html     = "<p>alpha\ngamma<div class=\"fourty two\"/>beta</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "block elements close para" do
      markdown = "alpha\n<div></div>beta"
      html     = "<p>alpha</p>\n<div></div>beta"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"></div>beta"
      html     = "<p>alpha</p>\n<div class=\"first\"></div>beta"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "block elements close para but only at BOL" do
      markdown = "alpha\n <div></div>beta"
      html     = "<p>alpha\n <div></div>beta</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"></div>beta"
      html     = "<p>alpha\ngamma<div class=\"fourty two\"></div>beta</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  # end
end

# SPDX-License-Identifier: Apache-2.0
