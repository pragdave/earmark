defmodule Acceptance.HtmlBlocksTest do
  use ExUnit.Case
  
  # describe "HTML blocks" do
    test "tables are just tables again (or was that mountains?)" do
      markdown = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table>\n\nokay.\n"
      # html     = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table><p>okay.</p>\n"
      ast = [{"table", [], [{"tr", [], [{"td", [], ["           hi    "]}]}]}, {"p", [], ["okay."]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "div (ine?)" do
      markdown = "<div>\n  *hello*\n         <foo><a>\n</div>\n"
      # html     = "<div>\n  *hello*\n         <foo><a>\n</div>"
      ast = {"div", [], ["  *hello*         ", {"foo", [], [{"a", [], []}]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "we are leaving html alone" do
      markdown = "<div>\n*Emphasized* text.\n</div>"
      # html     = "<div>\n*Emphasized* text.\n</div>"
      ast = {"div", [], ["*Emphasized* text."]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

  # end

  # describe "HTML void elements" do
    test "area" do
      markdown = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\">\n**emphasized** text"
      # html     = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\"><p><strong>emphasized</strong> text</p>\n"
      ast = [{"area",  [{"shape", "rect"}, {"coords", "0,0,1,1"}, {"href", "xxx"}, {"alt", "yyy"}],  []}, {"p", [], [{"strong", [], ["emphasized"]}, " text"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "we are outside the void now (lucky us)" do
      markdown = "<br>\n**emphasized** text"
      # html     = "<br><p><strong>emphasized</strong> text</p>\n"
      ast = [{"br", [], []}, {"p", [], [{"strong", [], ["emphasized"]}, " text"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "high regards???" do
      markdown = "<hr>\n**emphasized** text"
      # html     = "<hr><p><strong>emphasized</strong> text</p>\n"
      ast = [{"hr", [], []}, {"p", [], [{"strong", [], ["emphasized"]}, " text"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "img (a punless test)" do
      markdown = "<img src=\"hello\">\n**emphasized** text"
      # html     = "<img src=\"hello\"><p><strong>emphasized</strong> text</p>\n"
      ast = [{"img", [{"src", "hello"}], []}, {"p", [], [{"strong", [], ["emphasized"]}, " text"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "not everybode knows this one (hint: take a break)" do
      markdown = "<wbr>\n**emphasized** text"
      # html = "<wbr><p><strong>emphasized</strong> text</p>\n"
      ast = {"wbr", [], [{"p", [], [{"strong", [], ["emphasized"]}, " text"]}]}
      messages = []
      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end
  # end

  # describe "HTML and paragraphs" do
    test "void elements close para" do
      markdown = "alpha\n<hr>beta"
      # html     = "<p>alpha</p>\n<hr>beta"
      ast = [{"p", [], ["alpha"]}, {"hr", [], []}, "beta"]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "void elements close para but only at BOL" do
      markdown = "alpha\n <hr>beta"
      # html     = "<p>alpha\n <hr>beta</p>\n"
      ast = {"p", [], ["alpha ", {"hr", [], []}, "beta"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para" do
      markdown = "alpha\n<div/>beta"
      # html     = "<p>alpha</p>\n<div/>beta"
      ast = [{"p", [], ["alpha"]}, {"div", [], []}, "beta"]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"/>beta"
      # html     = "<p>alpha</p>\n<div class=\"first\"/>beta"
      ast = [{"p", [], ["alpha"]}, {"div", [{"class", "first"}], []}, "beta"]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para, atts and spaces do not matter" do
      markdown = "alpha\n<div class=\"first\"   />beta\ngamma"
      # html     = "<p>alpha</p>\n<div class=\"first\"   />beta<p>gamma</p>\n"
      ast = [{"p", [], ["alpha"]}, {"div", [{"class", "first"}], []}, "beta", {"p", [], ["gamma"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para but only at BOL" do
      markdown = "alpha\n <div/>beta"
      # html     = "<p>alpha\n <div/>beta</p>\n"
      ast = {"p", [], ["alpha ", {"div", [], []}, "beta"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "self closing block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"/>beta"
      # html     = "<p>alpha\ngamma<div class=\"fourty two\"/>beta</p>\n"
      ast = {"p", [], ["alpha\ngamma", {"div", [{"class", "fourty two"}], []}, "beta"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "block elements close para" do
      markdown = "alpha\n<div></div>beta"
      # html     = "<p>alpha</p>\n<div></div>beta"
      ast = [{"p", [], ["alpha"]}, {"div", [], []}, "beta"]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"></div>beta"
      # html     = "<p>alpha</p>\n<div class=\"first\"></div>beta"
      ast = [{"p", [], ["alpha"]}, {"div", [{"class", "first"}], []}, "beta"]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "block elements close para but only at BOL" do
      markdown = "alpha\n <div></div>beta"
      # html     = "<p>alpha\n <div></div>beta</p>\n"
      ast = {"p", [], ["alpha\n ", {"div", [], []}, "beta"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"></div>beta"
      # html     = "<p>alpha\ngamma<div class=\"fourty two\"></div>beta</p>\n"
      ast = {"p", [], ["alpha\ngamma", {"div", [{"class", "fourty two"}], []}, "beta"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

  # end
end
