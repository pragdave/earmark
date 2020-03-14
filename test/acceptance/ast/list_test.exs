defmodule Acceptance.Ast.ListTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  describe "List items" do
    test "Unnumbered" do
      markdown = "* one\n* two"
      html     = "<ul><li>one</li><li>two</li></ul>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Unnumbered Indented" do
      markdown = "  * one\n  * two"
      html     = "<ul><li>one</li><li>two</li></ul>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Unnumbered Indent taken into account" do
      markdown = "   * one\n     one.one\n   * two"
      html     = "<ul><li>one\none.one</li><li>two</li></ul>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Unnumbered two paras (removed from func tests)" do
      markdown = "* one\n\n    indent1\n"
      html     = "<ul><li><p>one</p><p>  indent1</p></li></ul>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    # Not GFM conformant, >3 goes into the head of the item
    test "Indented items, by 4 (removed from func tests)" do
      markdown = "1. one\n    - two\n        - three"
      html     = "<ol><li>one<ul><li>two<ul><li>three</li></ul></li></ul></li></ol>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "Numbered" do
      markdown = "1.  A paragraph\n    with two lines.\n\n        indented code\n\n    > A block quote.\n"
      html     = "<ol>\n<li><p> A paragraph\nwith two lines.</p>\n<pre><code>indented code</code></pre>\n<blockquote><p>A block quote.</p>\n</blockquote>\n</li>\n</ol>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "More numbers" do
      markdown = "1.  space one\n\n1. space two"
      html     = "<ol>\n<li><p> space one</p>\n</li>\n<li><p>space two</p>\n</li>\n</ol>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "can't count" do
      markdown = "- one\n\n two\n"
      html     = "<ul><li>one</li></ul><p> two</p>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "still not" do
      markdown = "- one\n- two"
      html     = "<ul><li>one</li><li>two</li></ul>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "the second one is not one" do
      markdown = "1. one\n1. two"
      html     = "<ol><li>one</li><li>two</li></ol>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "where shall we start" do
      markdown = "2. one\n3. two"
      html = "<ol start=\"2\"><li>one</li><li>two</li></ol>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "one?" do
      markdown = "2. one"
      html     = "<ol start=\"2\"><li>one</li></ol>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "count or no count?" do
      markdown = "-one\n\n2.two\n"
      html     = "<p>-one</p>\n<p>2.two</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "list or no list?" do
      markdown = "-1. not ok\n"
      html     = "<p>-1. not ok</p>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "no count or count?" do
      markdown = "1. foo\nbar"
      html     = "<ol><li>foo\nbar</li></ol>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "where does it end?" do
      markdown = "* a\n    b\nc"
      html     = "<ul>\n<li>a\n  b\nc</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "tables in lists? Maybe not" do
      markdown = "* x\n    a\n| A | B |"
      html     = "<ul>\n<li>x\n  a\n| A | B |</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "nice try, but naah" do
      markdown = "* x\n | A | B |"
      html     = "<ul>\n<li>x\n| A | B |</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "list after para" do
    test "indented (was regtest #13)" do
      markdown = """
    Para

    1. l1

    2. l2
  """
      html     = """
                     <p>  Para</p>
                     <ol>
                     <li><p>l1</p>
                     </li>
                     <li><p>l2</p>
                     </li>
                     </ol>
                  """
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
  # describe "Inline code" do
  #   @tag :wip
  #   test "perserves spaces" do
  #     markdown = "* \\`prefix`first\n*      second \\`\n* third` `suffix`"
  #     html     = "<p>`prefix<code class=\"inline\">first second \\</code>\n third<code class=\"inline\"></code>suffix`</p>\n"
  #     ast      = parse_html(html)
  #     messages = []

  #     assert as_ast(markdown) == {:ok, [ast], messages}
  #   end
  # end
end

# SPDX-License-Identifier: Apache-2.0
