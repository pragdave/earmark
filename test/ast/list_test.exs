defmodule Acceptance.ListTest do
  use ExUnit.Case

  describe "List items" do
    test "Unnumbered" do
      markdown = "* one\n* two"
      # html     = "<ul>\n<li>one\n</li>\n<li>two\n</li>\n</ul>\n"
      ast = {"ul", [], [{"li", [], ["one"]}, {"li", [], ["two"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "Unnumbered Indented" do
      markdown = "  * one\n  * two"
      # html     = "<ul>\n<li>one\n</li>\n<li>two\n</li>\n</ul>\n"
      ast = {"ul", [], [{"li", [], ["one"]}, {"li", [], ["two"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "Unnumbered Indent taken into account" do
      markdown = "   * one\n     one.one\n   * two"
      # html     = "<ul>\n<li>one\n one.one\n</li>\n<li>two\n</li>\n</ul>\n"
      ast = {"ul", [], [{"li", [], ["one one.one"]}, {"li", [], ["two"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}

    end
    test "Numbered" do
      markdown = "1.  A paragraph\n    with two lines.\n\n        indented code\n\n    > A block quote.\n"
      # html     = "<ol>\n<li><p>A paragraph\nwith two lines.</p>\n<pre><code>indented code</code></pre>\n<blockquote><p>A block quote.</p>\n</blockquote>\n</li>\n</ol>\n"
      ast = {"ol", [], [{"li", [],   [{"p", [], ["A paragraphwith two lines."]},    {"pre", [], [{"code", [], ["indented code"]}]},    {"blockquote", [], [{"p", [], ["A block quote."]}]}]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "More numbers" do
      markdown = "1.  space one\n\n1. space two"
      # html     = "<ol>\n<li><p>space one</p>\n</li>\n<li><p>space two</p>\n</li>\n</ol>\n"
      ast = {"ol", [], [{"li", [], [{"p", [], ["space one"]}]},  {"li", [], [{"p", [], ["space two"]}]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "can't count" do
      markdown = "- one\n\n two\n"
      # html     = "<ul>\n<li>one\n</li>\n</ul>\n<p> two</p>\n"
      ast = [{"ul", [], [{"li", [], ["one"]}]}, {"p", [], [" two"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "still not" do
      markdown = "- one\n- two"
      # html     = "<ul>\n<li>one\n</li>\n<li>two\n</li>\n</ul>\n"
      ast = {"ul", [], [{"li", [], ["one"]}, {"li", [], ["two"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "the second one is not one" do
      markdown = "1. one\n1. two"
      # html     = "<ol>\n<li>one\n</li>\n<li>two\n</li>\n</ol>\n"
      ast = {"ol", [], [{"li", [], ["one"]}, {"li", [], ["two"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "where shall we start" do
      markdown = "2. one\n3. two"
      # html = "<ol start=\"2\">\n<li>one\n</li>\n<li>two\n</li>\n</ol>\n"
      ast = {"ol", [{"start", "2"}], [{"li", [], ["one\n"]}, {"li", [], ["two"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "one?" do
      markdown = "2. one"
      # html     = "<ol start=\"2\">\n<li>one\n</li>\n</ol>\n"
      ast = {"ol", [{"start", "2"}], [{"li", [], ["one\n"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "count or no count?" do
      markdown = "-one\n\n2.two\n"
      # html     = "<p>-one</p>\n<p>2.two</p>\n"
      ast = [{"p", [], ["-one"]}, {"p", [], ["2.two"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "list or no list?" do
      markdown = "-1. not ok\n"
      # html     = "<p>-1. not ok</p>\n"
      ast = {"p", [], ["-1. not ok"]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "no count or count?" do
      markdown = "1. foo\nbar"
      # html     = "<ol>\n<li>foo\nbar\n</li>\n</ol>\n"
      ast = {"ol", [], [{"li", [], ["foobar"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "where does it end?" do
      markdown = "* a\n    b\nc"
      # html     = "<ul>\n<li>a\nb\nc\n</li>\n</ul>\n"
      ast = {"ul", [], [{"li", [], ["a\nb\nc"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "tables in lists? Maybe not" do
      markdown = "* x\n    a\n| A | B |"
      # html     = "<ul>\n<li>x\na\n| A | B |\n</li>\n</ul>\n"
      ast = {"ul", [], [{"li", [], ["x\na\n| A | B |"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "nice try, but naah" do
      markdown = "* x\n | A | B |"
      # html     = "<ul>\n<li>x\n | A | B |\n</li>\n</ul>\n"
      ast = {"ul", [], [{"li", [], ["x\n | A | B |"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

  end
end
