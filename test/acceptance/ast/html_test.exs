defmodule Acceptance.Ast.HtmlBlocksTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import Support.AstHelpers, only: [p: 1, void_tag: 1]
  
  @verbatim %{meta: %{verbatim: true}}

  describe "HTML blocks" do
    test "tables are just tables again (or was that mountains?)" do
      markdown = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table>\n\nokay.\n"
      ast      = [
        {"table", [], ["  <tr>", "    <td>", "           hi", "    </td>", "  </tr>"], @verbatim},
        {"p", [], ["okay."]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "div (ine?)" do
      markdown = "<div>\n  *hello*\n         <foo><a>\n</div>\n"
      ast      = [{"div", [], ["  *hello*", "         <foo><a>"], @verbatim}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "we are leaving html alone" do
      markdown = "<div>\n*Emphasized* text.\n</div>"
      ast      = [{"div", [], ["*Emphasized* text."], @verbatim}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "even block elements" do
      markdown = "<div>\n```elixir\ndefmodule Mine do\n```\n</div>"
      ast      = [{"div", [], ["```elixir", "defmodule Mine do", "```"], @verbatim}]
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
      ast      = [p("alpha"), void_tag("hr"), "beta"]
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
      ast      =[{"p", [], ["alpha"]}, {"div", [], []}, "beta"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"/>beta"
      # We ignore beta now shall we deprecate for HTML????
      ast      = [{"p", [], ["alpha"]}, {"div", [{"class", "first"}], []}, "beta"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para, atts and spaces do not matter" do
      markdown = "alpha\n<div class=\"first\"   />beta\ngamma"
      # We ignore beta now shall we deprecate for HTML????
      ast      = [{"p", [], ["alpha"]}, {"div", [{"class", "first"}], []}, "beta", {"p", [], ["gamma"]}]
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
      ast      = [{"p", [], ["alpha"]}, {"div", [], ["</div>beta"]}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"></div>beta"
      # SIC just do not write that markup
      ast      = [{"p", [], ["alpha"]}, {"div", [{"class", "first"}], ["</div>beta"]}]
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

  describe "multiple tags in closing line" do
    test "FTF" do
      markdown = "<div class=\"my-div\">\nline\n</div>"
      ast      = [{"div", [{"class", "my-div"}], ["line"], @verbatim}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "this is not closing" do
      markdown = "<div>\nline\n</hello></div>"
      ast      = [{"div", [], ["line", "</hello></div>"], @verbatim}]
      messages = [{:warning, 1, "Failed to find closing <div>"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end
    test "therefore the div continues" do
      markdown = "<div>\nline\n</hello></div>\n</div>"
      ast      = [{"div", [], ["line", "</hello></div>"], @verbatim}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "...nor is this" do
      markdown = "<div>\nline\n<hello></div>"
      ast      = [{"div", [], ["line", "<hello></div>"], @verbatim}]
      messages = [{:warning, 1, "Failed to find closing <div>"},
        {:warning, 3, "Failed to find closing <hello>"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end
    test "however, this closes and keeps the garbage" do
      markdown = "<div>\nline\n</div><hello>"
      ast      = [{"div", [], ["line"], @verbatim}, "<hello>"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "however, this closes and keeps **whatever** garbage" do
      markdown = "<div>\nline\n</div> `garbage`"
      ast      = [{"div", [], ["line"], @verbatim}, "`garbage`"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "however, this closes and keeps not even warnings" do
      markdown = "<div>\nline\n</div> `garbage"
      ast      = [{"div", [], ["line"], @verbatim}, "`garbage"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "however, this closes and kept garbage is not even inline formatted" do
      markdown = "<div>\nline\n</div> _garbage_"
      ast      = [{"div", [], ["line"], @verbatim}, "_garbage_"]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "arbitrary tags" do
    # Needs a fix with issue [#326](https://github.com/pragdave/earmark/issues/326)
    @tag :wip
    test "mixture of tags (was regtest #103)" do 
      markdown = "<x>a\n<y></y>\n<y>\n<z>\n</z>\n<z>\n</x>"
      html     = "<x>a\n<y></y>\n<y>\n<z>\n</z>\n<z>\n</x>"
      ast      = parse_html(html)
      messages = Enum.zip(1..3, ~w[x y z])
                 |> Enum.map(fn {lnb, tag} -> {:warning, lnb, "Failed to find closing <#{tag}>"} end)

      assert as_ast(markdown) == {:error, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
