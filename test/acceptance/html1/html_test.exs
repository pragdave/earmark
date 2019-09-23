defmodule Acceptance.Html1.Html1BlocksTest do
  use ExUnit.Case, async: true
  
  import Support.Helpers, only: [as_html: 1]
  import Support.Html1Helpers
  
  @moduletag :html1

  describe "HTML blocks" do
    test "tables are just tables again (or was that mountains?)" do
      markdown = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table>\n\nokay.\n"
      html     = construct([
        {:table, nil, {:tr, nil, {:td, nil, "           hi"}}},
        {:p, nil, "okay."} ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "div (ine?)" do
      markdown = "<div>\n  *hello*\n         <foo><a>\n</div>\n"
      html     = construct({:div, nil, ["  *hello*", "         &lt;foo&gt;&lt;a&gt;"]})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "we are leaving html alone" do
      markdown = "<div>\n*Emphasized* text.\n</div>"
      html     = construct({:div, nil, "*Emphasized* text."})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end

  describe "HTML void elements" do
    test "area" do
      markdown = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\">\n**emphasized** text"
      html     = construct([
        {:area, ~s{shape="rect" coords="0,0,1,1" href="xxx" alt="yyy"}},
        {:p, nil, [{:strong, nil, "emphasized"}, " text"]}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "we are outside the void now (lucky us)" do
      markdown = "<br>\n**emphasized** text"
      html     = construct([
        :br,
        {:p, nil, [{:strong, nil, "emphasized"}, " text"]}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "high regards???" do
      markdown = "<hr />\n**emphasized** text"
      html     = construct([
        :hr,
        {:p, nil, [{:strong, nil, "emphasized"}, " text"]}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "img (a punless test)" do
      markdown = "<img src=\"hello\">\n**emphasized** text"
      html     = construct([
        {:img, ~s{src="hello"}},
        {:p, nil, [{:strong, nil, "emphasized"}, " text"]}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "not everybode knows this one (hint: take a break)" do
      markdown = "<wbr>\n**emphasized** text"
      html     = construct([
        :wbr,
        {:p, nil, [{:strong, nil, "emphasized"}, " text"]}])
      messages = []
      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "HTML and paragraphs" do
    test "void elements close para" do
      markdown = "alpha\n<hr />beta"
      html     = construct([
        {:p, nil, "alpha"},
        :hr
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "void elements close para but only at BOL" do
      markdown = "alpha\n <hr />beta"
      html     = para("alpha\n &lt;hr /&gt;beta")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para" do
      markdown = "alpha\n<div/>beta"
      html     = construct([
        {:p, nil, "alpha"},
        "<div></div>"
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"/>beta"
      html     = construct([
        {:p, nil, "alpha"},
        "<div class=\"first\"></div>"
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para, atts and spaces do not matter" do
      markdown = "alpha\n<div class=\"first\"   />beta\ngamma"
      html     = construct([
        {:p, nil, "alpha"},
        "<div class=\"first\"></div>",
        :p, "gamma" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para but only at BOL" do
      markdown = "alpha\n <div/>beta"
      html     = para("alpha\n &lt;div/&gt;beta")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "self closing block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"/>beta"
      html     = para("alpha\ngamma&lt;div class=&quot;fourty two&quot;/&gt;beta")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "block elements close para" do
      markdown = "alpha\n<div></div>beta"
      html     = construct([
        {:p, nil, "alpha"},
        "<div></div>"
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "block elements close para, atts do not matter" do
      markdown = "alpha\n<div class=\"first\"></div>beta"
      html     = "<p>alpha</p>\n<div class=\"first\"></div>beta"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "block elements close para but only at BOL" do
      markdown = "alpha\n <div></div>beta"
      html     = para("alpha\n &lt;div&gt;&lt;/div&gt;beta")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "block elements close para but only at BOL, atts do not matter" do
      markdown = "alpha\ngamma<div class=\"fourty two\"></div>beta"
      html     = para("alpha\ngamma&lt;div class=&quot;fourty two&quot;&gt;&lt;/div&gt;beta")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
