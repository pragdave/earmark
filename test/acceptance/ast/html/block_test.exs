defmodule Acceptance.Ast.Html.BlockTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl

  @verbatim %{verbatim: true}

  describe "HTML blocks" do
    test "tables are just tables again (or was that mountains?)" do
      markdown =
        "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table>\n\nokay.\n"

      ast = [
        {"table", [], ["  <tr>", "    <td>", "           hi", "    </td>", "  </tr>"], @verbatim},
        p("okay.")
      ]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "div (ine?)" do
      markdown = "<div>\n  *hello*\n         <foo><a>\n</div>\n"
      ast = [vtag("div", ["  *hello*", "         <foo><a>"])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "we are leaving html alone" do
      markdown = "<div>\n*Emphasized* text.\n</div>"
      ast = [vtag("div", "*Emphasized* text.")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "even block elements" do
      markdown = "<div>\n```elixir\ndefmodule Mine do\n```\n</div>"
      ast = [vtag("div", ["```elixir", "defmodule Mine do", "```"])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "HTML void elements" do
    test "area" do
      markdown =
        "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\">\n**emphasized** text"
      ast = [
        vtag("area", nil, shape: "rect", coords: "0,0,1,1", href: "xxx", alt: "yyy"),
        p([tag("strong", "emphasized"), " text"])
      ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "we are outside the void now (lucky us)" do
      markdown = "<br>\n**emphasized** text"
      ast = [
        vtag("br"),
        p([tag("strong", "emphasized"), " text"])
      ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "high regards???" do
      markdown = "<hr>\n**emphasized** text"
      ast = [vtag("hr"), p([tag("strong", "emphasized"), " text"])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "img (a punless test)" do
      markdown = "<img src=\"hello\">\n**emphasized** text"
      ast = [vtag("img", [], src: "hello"), p([tag("strong", "emphasized"), " text"])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "not everybody knows this one (hint: take a break)" do
      markdown = "<wbr>\n**emphasized** text"
      ast = [
        vtag("wbr"),
        p([tag("strong", "emphasized"), " text"])
      ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "HTML and paragraphs" do
    test "void elements close para" do
      markdown = "alpha\n<hr>beta"
      ast = [p("alpha"), vtag("hr"), "beta"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "void elements close para but only at BOL" do
      markdown = "alpha\n <hr>beta"
      ast = [p("alpha\n <hr>beta")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para" do
      markdown = "alpha\n<div/>beta"
      ast = [p("alpha"), vtag("div"), "beta"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"/>beta"
      ast = [p("alpha"), vtag("div", nil, class: "first"), "beta"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para, atts and spaces do not matter" do
      markdown = "alpha\n<div class=\"first\"   />beta\ngamma"
      ast = [
        p("alpha"),
        vtag("div", nil, class: "first"),
        "beta",
        p("gamma")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para but only at BOL" do
      markdown = "alpha\n <div/>beta"
      # SIC just do not write that markup
      ast = [p("alpha\n <div/>beta")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"/>beta"
      # SIC just do not write that markup
      ast = [p("alpha\ngamma<div class=\"fourty two\"/>beta")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "block elements close para" do
      markdown = "alpha\n<div></div>beta"
      # SIC just do not write that markup
      ast = [p("alpha"), vtag("div")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"></div>beta"
      # SIC just do not write that markup
      ast = [p("alpha"), vtag("div", [], class: "first")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "block elements close para but only at BOL" do
      markdown = "alpha\n <div></div>beta"
      # SIC just do not write that markup
      ast = [p("alpha\n <div></div>beta")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"></div>beta"
      # SIC just do not write that markup
      ast = [p("alpha\ngamma<div class=\"fourty two\"></div>beta")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "multiple tags in closing line" do
    test "FTF" do
      markdown = "<div class=\"my-div\">\nline\n</div>"
      ast = vtag("div", "line", class: "my-div")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "parses unquoted attrs" do
      markdown = "<div class=my-div >\nline\n</div>"
      ast = [vtag("div", "line")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "this is not closing" do
      markdown = "<div>\nline\n</hello></div>"
      ast = [{"div", [], ["line", "</hello></div>"], @verbatim}]
      messages = [{:warning, 1, "Failed to find closing <div>"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end

    test "therefore the div continues" do
      markdown = "<div>\nline\n</hello></div>\n</div>"
      ast = [vtag("div", ["line", "</hello></div>"])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "...nor is this" do
      markdown = "<div>\nline\n<hello></div>"
      ast = [vtag("div", ["line", "<hello></div>"])]
      messages = [
        {:warning, 1, "Failed to find closing <div>"},
        {:warning, 3, "Failed to find closing <hello>"}
      ]

      assert as_ast(markdown) == {:error, ast, messages}
    end

    test "however, this closes and keeps the garbage" do
      markdown = "<div>\nline\n</div><hello>"
      ast = [vtag("div", "line"), "<hello>"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "however, this closes and keeps **whatever** garbage" do
      markdown = "<div>\nline\n</div> `garbage`"
      ast = [vtag("div", "line"), "`garbage`"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "however, this closes and kept garbage is not even inline formatted" do
      markdown = "<div>\nline\n</div> _garbage_"
      ast = [vtag("div", "line"), "_garbage_"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
