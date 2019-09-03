defmodule Functional.Ast.Renderer.HtmlRendererTest do
  use ExUnit.Case, async: true
  
  import Earmark.Ast.Renderer.HtmlRenderer, only: [render_html_block: 1]

  describe "rendering of HTML Blocks as an ast" do
    test "empty" do
      html_lines = [
      ]
      assert render_html_block(html_lines) == []
    end

    test "not so flat" do
      html_lines = [ 
        "<div class='a'>", "content", "</div>"
      ]
      expected = {"div", [{"class", "a"}], ["content"]}

      assert render_html_block(html_lines) == expected
    end

    test "in the middle" do
      html_lines = [ 
        "<div class='a'>", 
        "<span>", "something", "</span>",
        "content",
        "</div>",
        "suffix"
      ]
      expected = {"div", [{"class", "a"}], [{"span", [], ["something"]}, "content"]}

      assert render_html_block(html_lines) == expected
    end

    test "tags need to be on their own lines" do
      html_lines = [ 
        "<div class='a'>", 
        "<span><a>",
        "</div>",
        "suffix"
      ]
      expected = {"div", [{"class", "a"}], ["<span><a>"]}

      assert render_html_block(html_lines) == expected
    end

  end

  describe "handling warnings (emitted by the parser though)" do
    test "unclosed tag" do
      html_lines = [ 
        "<div>", 
        "<foo>",
        "content",
        "</div>",
      ]
      expected = {"div", [], ["<foo>", "content"]}
      
      assert render_html_block(html_lines) == expected
    end

    test "and some" do
      html_lines = [ 
        "<div>", 
        "<foo>",
        "<bar>",
        "content",
        "</foo>",
      ]
      expected = {"div", [], [{"foo", [], ["<bar>", "content"]}]}

      assert render_html_block(html_lines) == expected
    end

    test "more unclosed and beware of order" do
      html_lines = [
        "<div>",
        "alpha",
        "<span class='a'>",
        "beta",
        "gamma",
        "<strong>",
        "delta",
        "epsilon",
        "</div>"
      ]
      expected = {"div", [], ["alpha", "<span class=\"a\">", "beta", "gamma", "<strong>", "delta", "epsilon"]}

      assert render_html_block(html_lines) == expected
    end
  end
end
