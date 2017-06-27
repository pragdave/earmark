defmodule Acceptance.HorizontalRulesTest do
  use ExUnit.Case
  
  # describe "Horizontal rules" do

    test "thick, thin & medium" do
      markdown = "***\n---\n___\n"
      # html     = "<hr class=\"thick\"/>\n<hr class=\"thin\"/>\n<hr class=\"medium\"/>\n"
      ast = [{"hr", [{"class", "thick"}], []}, {"hr", [{"class", "thin"}], []}, {"hr", [{"class", "medium"}], []}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "not a rule" do
      markdown = "+++\n"
      # html     = "<p>+++</p>\n"
      ast = {"p", [], ["+++"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "not in code" do
      markdown = "    ***\n    \n     a"
      # html     = "<pre><code>***\n\n a</code></pre>\n"
      ast = {"pre", [], [{"code", [], ["***\n\n a"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "not in code, second line" do
      markdown = "Foo\n    ***\n"
      # html     = "<p>Foo</p>\n<pre><code>***</code></pre>\n"
      ast = [{"p", [], ["Foo"]}, {"pre", [], [{"code", [], ["***"]}]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "medium, long" do
      markdown = "_____________________________________\n"
      # html     = "<hr class=\"medium\"/>\n"
      ast = {"hr", [{"class", "medium"}], []}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "emmed, so to speak" do
      markdown = " *-*\n"
      # html     = "<p> <em>-</em></p>\n"
      ast = {"p", [], [{"em", [], ["-"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "in lists" do
      markdown = "- foo\n***\n- bar\n"
      # html     = "<ul>\n<li>foo\n</li>\n</ul>\n<hr class=\"thick\"/>\n<ul>\n<li>bar\n</li>\n</ul>\n"
      ast = [{"ul", [], [{"li", [], ["foo"]}]}, {"hr", [{"class", "thick"}], []}, {"ul", [], [{"li", [], ["bar"]}]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "setext rules over rules (why am I soo witty?)" do
      markdown = "Foo\n---\nbar\n"
      # html     = "<h2>Foo</h2>\n<p>bar</p>\n"
      ast = [{"h2", [], ["Foo"]}, {"p", [], ["bar"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "in lists, thick this time (why am I soo good to you?)" do
      markdown = "* Foo\n* * *\n* Bar\n"
      # html = "<ul>\n<li>Foo\n</li>\n</ul>\n<hr class=\"thick\"/>\n<ul>\n<li>Bar\n</li>\n</ul>\n"
      ast = [{"ul", [], [{"li", [], ["Foo"]}]}, {"hr", [{"class", "thick"}], []}, {"ul", [], [{"li", [], ["Bar"]}]}]
      messages = []
      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end
  # end
end
