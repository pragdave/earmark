defmodule Acceptance.Ast.HtmlBlocksTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  @moduletag :ast

  describe "HTML blocks" do
    test "tables are just tables again (or was that mountains?)" do
      markdown = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table>\n\nokay.\n"
      html     = "<table>\n  <tr>\n    <td>           hi</td>\n  </tr>\n</table><p>okay.</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "div (ine?)" do
      markdown = "<div>\n  *hello*\n         <foo><a>\n</div>\n"
      ast      = [{"div", [], ["  *hello*", "         <foo><a>"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "we are leaving html alone" do
      markdown = "<div>\n*Emphasized* text.\n</div>"
      ast      = [{"div", [], ["*Emphasized* text."]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

  end

  describe "HTML void elements" do
    test "area" do
      markdown = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\">\n**emphasized** text"
      html     = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\"><p><strong>emphasized</strong> text</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "we are outside the void now (lucky us)" do
      markdown = "<br>\n**emphasized** text"
      html     = "<br><p><strong>emphasized</strong> text</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "high regards???" do
      markdown = "<hr>\n**emphasized** text"
      html     = "<hr><p><strong>emphasized</strong> text</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "img (a punless test)" do
      markdown = "<img src=\"hello\">\n**emphasized** text"
      html     = "<img src=\"hello\"><p><strong>emphasized</strong> text</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "not everybody knows this one (hint: take a break)" do
      markdown = "<wbr>\n**emphasized** text"
      html = "<wbr><p><strong>emphasized</strong> text</p>\n"
      ast      = parse_html(html)
      messages = []
      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "HTML and paragraphs" do
    test "void elements close para" do
      markdown = "alpha\n<hr>beta"
      # We ignore beta now shall we deprecate for HTML????
      ast      = [{"p", [], ["alpha"]}, {"hr", [], []}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "void elements close para but only at BOL" do
      markdown = "alpha\n <hr>beta"
      ast      = [{"p", [], ["alpha\n <hr>beta"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para" do
      markdown = "alpha\n<div/>beta"
      # We ignore beta now shall we deprecate for HTML????
      ast      =[{"p", [], ["alpha"]}, {"div", [], []}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"/>beta"
      # We ignore beta now shall we deprecate for HTML????
      ast      = [{"p", [], ["alpha"]}, {"div", [{"class", "first"}], []}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para, atts and spaces do not matter" do
      markdown = "alpha\n<div class=\"first\"   />beta\ngamma"
      # We ignore beta now shall we deprecate for HTML????
      ast      = [{"p", [], ["alpha"]}, {"div", [{"class", "first"}], []}, {"p", [], ["gamma"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para but only at BOL" do
      markdown = "alpha\n <div/>beta"
      # SIC just do not write that markup
      ast      = [{"p", [], ["alpha\n <div/>beta"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"/>beta"
      # SIC just do not write that markup
      ast      = [{"p", [], ["alpha\ngamma<div class=\"fourty two\"/>beta"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "block elements close para" do
      markdown = "alpha\n<div></div>beta"
      # SIC just do not write that markup
      ast      = [{"p", [], ["alpha"]}, {"div", [], []}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"></div>beta"
      # SIC just do not write that markup
      ast      = [{"p", [], ["alpha"]}, {"div", [{"class", "first"}], []}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "block elements close para but only at BOL" do
      markdown = "alpha\n <div></div>beta"
      # SIC just do not write that markup
      ast      = [{"p", [], ["alpha\n <div></div>beta"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"></div>beta"
      # SIC just do not write that markup
      ast      = [{"p", [], ["alpha\ngamma<div class=\"fourty two\"></div>beta"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
