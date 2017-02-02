defmodule Acceptance.ListTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_html: 1]

  # describe "List items" do
    test "Numbered" do
      markdown = "1.  A paragraph\n    with two lines.\n\n        indented code\n\n    > A block quote.\n"
      html     = "<ol>\n<li><p>A paragraph\nwith two lines.</p>\n<pre><code>indented code</code></pre>\n<blockquote><p>A block quote.</p>\n</blockquote>\n</li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "More numbers" do
      markdown = "1.  space one\n\n1. space two"
      html     = "<ol>\n<li><p>space one</p>\n</li>\n<li><p>space two</p>\n</li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "can't count" do
      markdown = "- one\n\n two\n"
      html     = "<ul>\n<li>one\n</li>\n</ul>\n<p> two</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "still not" do
      markdown = "- one\n- two"
      html     = "<ul>\n<li>one\n</li>\n<li>two\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "the second one is not one" do
      markdown = "1. one\n1. two"
      html     = "<ol>\n<li>one\n</li>\n<li>two\n</li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "where shall we start" do
      markdown = "2. one\n3. two"
      html = "<ol start=\"2\">\n<li>one\n</li>\n<li>two\n</li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "one?" do
      markdown = "2. one"
      html     = "<ol start=\"2\">\n<li>one\n</li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "count or no count?" do
      markdown = "-one\n\n2.two\n"
      html     = "<p>-one</p>\n<p>2.two</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "list or no list?" do
      markdown = "-1. not ok\n"
      html     = "<p>-1. not ok</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "no count or count?" do
      markdown = "1. foo\nbar"
      html     = "<ol>\n<li>foo\nbar\n</li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "where does it end?" do
      markdown = "* a\n    b\nc"
      html     = "<ul>\n<li>a\nb\nc\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "tables in lists? Maybe not" do
      markdown = "* x\n    a\n| A | B |"
      html     = "<ul>\n<li>x\na\n| A | B |\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "nice try, but naah" do
      markdown = "* x\n | A | B |"
      html     = "<ul>\n<li>x\n | A | B |\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  # end
end
