defmodule Acceptance.AcceptanceTest do
  use ExUnit.Case

  #
  # Horizontal Rules
  #
  describe "Horizontal rules" do
    test "" do
      markdown = "***\n---\n___\n"
      html = "<hr class=\"thick\"/>\n<hr class=\"thin\"/>\n<hr class=\"medium\"/>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "+++\n"
      html = "<p>+++</p>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "    ***\n    \n     a"
      html = "<pre><code>***\n\n a</code></pre>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "Foo\n    ***\n"
      html = "<p>Foo</p>\n<pre><code>***</code></pre>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "_____________________________________\n"
      html = "<hr class=\"medium\"/>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = " *-*\n"
      html = "<p> <em>-</em></p>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "- foo\n***\n- bar\n"
      html = "<ul>\n<li>foo\n</li>\n</ul>\n<hr class=\"thick\"/>\n<ul>\n<li>bar\n</li>\n</ul>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "Foo\n---\nbar\n"
      html = "<h2>Foo</h2>\n<p>bar</p>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "* Foo\n* * *\n* Bar\n"
      html = "<ul>\n<li>Foo\n</li>\n</ul>\n<hr class=\"thick\"/>\n<ul>\n<li>Bar\n</li>\n</ul>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
  end

  #
  # ATX Headers
  #
  describe "ATX headers" do
    test "" do
      markdown = "# foo\n## foo\n### foo\n#### foo\n##### foo\n###### foo\n"
      html = "<h1>foo</h1>\n<h2>foo</h2>\n<h3>foo</h3>\n<h4>foo</h4>\n<h5>foo</h5>\n<h6>foo</h6>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "####### foo\n"
      html = "<p>####### foo</p>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "#5 bolt\n\n#foobar\n"
      html = "<p>#5 bolt</p>\n<p>#foobar</p>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "\\## foo\n"
      html = "<p>## foo</p>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "# foo *bar* \\*baz\\*\n"
      html = "<h1>foo <em>bar</em> *baz*</h1>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "#                  foo                     \n"
      html = "<h1>foo</h1>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "    # foo\nnext"
      html = "<pre><code># foo</code></pre>\n<p>next</p>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "# foo#\n"
      html = "<h1>foo</h1>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "### foo ### "
      html = "<h3>foo ###</h3>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
  end

  #
  # Setext Headers
  #
  describe "Setext headers" do
    test "" do
      markdown = "Foo *bar*\n=========\n\nFoo *bar*\n---------\n"
      html = "<h1>Foo <em>bar</em></h1>\n<h2>Foo <em>bar</em></h2>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "Foo\n-------------------------\n\nFoo\n=\n"
      html = "<h2>Foo</h2>\n<h1>Foo</h1>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "" do
      markdown = "Foo\\\n----\n"
      html = "<h2>Foo\\</h2>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end

    # There is no consensus on this one, I prefer to not define the behavior of this unless
    # there is a real use case
    # c.f. http://johnmacfarlane.net/babelmark2/?text=%60Foo%0A----%0A%60%0A%0A%3Ca+title%3D%22a+lot%0A---%0Aof+dashes%22%2F%3E%0A
    #  {
      #    "section": "Setext headers"
      #    "html": "<h2>`Foo</h2>\n<p>`</p>\n<h2>&lt;a title=&quot;a lot</h2>\n<p>of dashes&quot;/&gt;</p>\n"
      #    "markdown": "`Foo\n----\n`\n\n<a title=\"a lot\n---\nof dashes\"/>\n"
      #  end
end

#
# Indented Code Blocks
#
describe "Indented code blocks" do
  test "" do
    markdown = "    a simple\n      indented code block\n"
    html = "<pre><code>a simple\n  indented code block</code></pre>\n"
    messages = []
    assert Earmark.as_html(markdown) == {html, messages}
  end
  test "" do
    markdown = "    <a/>\n    *hi*\n\n    - one\n"
    html = "<pre><code>&lt;a/&gt;\n*hi*\n\n- one</code></pre>\n"
    messages = []
    assert Earmark.as_html(markdown) == {html, messages}
  end
  test "" do
    markdown = "    chunk1\n\n    chunk2\n  \n \n \n    chunk3\n"
    html = "<pre><code>chunk1\n\nchunk2\n\n\n\nchunk3</code></pre>\n"
    messages = []
    assert Earmark.as_html(markdown) == {html, messages}
  end
  test "" do
    markdown = "    foo\nbar\n"
    html = "<pre><code>foo</code></pre>\n<p>bar</p>\n"
    messages = []
    assert Earmark.as_html(markdown) == {html, messages}
  end
  test "" do
    markdown = "\n    \n    foo\n    \n\n"
    html = "<pre><code>foo</code></pre>\n"
    messages = []
    assert Earmark.as_html(markdown) == {html, messages}
  end
end

#
# Fenced Code Blocks
#
describe "Fenced code blocks" do
  test "" do
    markdown = "```\n<\n >\n```\n"
    html = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
    messages = []
    assert Earmark.as_html(markdown) == {html, messages}
  end
  test "" do
    markdown = "~~~\n<\n >\n~~~\n"
    html = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
    messages = []
    assert Earmark.as_html(markdown) == {html, messages}
  end
  test "" do
    markdown = "```elixir\naaa\n~~~\n```\n"
    html = "<pre><code class=\"elixir\">aaa\n~~~</code></pre>\n"
    messages = []
    assert Earmark.as_html(markdown) == {html, messages}
  end
  test "with a code_block_prefix" do
    options = { "code_block_prefix": "lang-" end
      markdown = "```elixir\naaa\n~~~\n```\n"
      "html": "<pre><code class=\"elixir\">aaa\n~~~</code></pre>\n"
      messages = []
end
test "" do
  markdown = "   ```\naaa\nb\n  ```\n"
  html = "<pre><code class=\"\">aaa\nb</code></pre>\n"
  messages = []
  assert Earmark.as_html(markdown) == {html, messages}
end
    end

    #
    # HTML Blocks
    #
    describe "HTML blocks" do
      test "" do
        markdown = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table>\n\nokay.\n"
        html = "<table>\n  <tr>\n    <td>\n           hi\n    </td>\n  </tr>\n</table><p>okay.</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<div>\n  *hello*\n         <foo><a>\n</div>\n"
        html = "<div>\n  *hello*\n         <foo><a>\n</div>"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<div>\n*Emphasized* text.\n</div>"
        html = "<div>\n*Emphasized* text.\n</div>"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # HTML Void Elements
    #
    describe "HTML void elements" do
      test "" do
        markdown = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\">\n**emphasized** text"
        html = "<area shape=\"rect\" coords=\"0,0,1,1\" href=\"xxx\" alt=\"yyy\"><p><strong>emphasized</strong> text</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<br>\n**emphasized** text"
        html = "<br><p><strong>emphasized</strong> text</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<hr>\n**emphasized** text"
        html = "<hr><p><strong>emphasized</strong> text</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<img src=\"hello\">\n**emphasized** text"
        html = "<img src=\"hello\"><p><strong>emphasized</strong> text</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<wbr>\n**emphasized** text"
        html = "<wbr><p><strong>emphasized</strong> text</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # HTML and paragraphs
    #
    describe "HTML and paragraphs" do
      test "void elements close para" do
        markdown = "alpha\n<hr>beta"
        html = "<p>alpha</p>\n<hr>beta"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "void elements close para but only at BOL" do
        markdown = "alpha\n <hr>beta"
        html = "<p>alpha\n <hr>beta</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "self closing block elements close para" do
        markdown = "alpha\n<div/>beta"
        html = "<p>alpha</p>\n<div/>beta"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "self closing block elements close para, atts do not matter" do
        markdown = "alpha\n<div class=\"first\"/>beta"
        html = "<p>alpha</p>\n<div class=\"first\"/>beta"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "self closing block elements close para, atts and spaces do not matter" do
        markdown = "alpha\n<div class=\"first\"   />beta\ngamma"
        html = "<p>alpha</p>\n<div class=\"first\"   />beta<p>gamma</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "self closing block elements close para but only at BOL" do
        markdown = "alpha\n <div/>beta"
        html = "<p>alpha\n <div/>beta</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "self closing block elements close para but only at BOL, atts do not matter" do
        markdown = "alpha\ngamma<div class=\"fourty two\"/>beta"
        html = "<p>alpha\ngamma<div class=\"fourty two\"/>beta</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "block elements close para" do
        markdown = "alpha\n<div></div>beta"
        html = "<p>alpha</p>\n<div></div>beta"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "block elements close para, atts do not matter" do
        markdown = "alpha\n<div class=\"first\"></div>beta"
        html = "<p>alpha</p>\n<div class=\"first\"></div>beta"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "block elements close para but only at BOL" do
        markdown = "alpha\n <div></div>beta"
        html = "<p>alpha\n <div></div>beta</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "block elements close para but only at BOL, atts do not matter" do
        markdown = "alpha\ngamma<div class=\"fourty two\"></div>beta"
        html = "<p>alpha\ngamma<div class=\"fourty two\"></div>beta</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Link Reference Definitions
    #
    describe "Link reference definitions" do
      test "" do
        markdown = "[foo]: /url \"title\"\n\n[foo]\n"
        html = "<p><a href=\"/url\" title=\"title\">foo</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[foo]: /url \"title\"\n\n[bar]\n"
        html = "<p>[bar]</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[foo]: /url \"title\"\n\n![foo]\n"
        html = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[foo]: /url \"title\"\n\n![bar]\n"
        html = "<p>![bar]</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[foo]\n\n[foo]: url\n"
        html = "<p><a href=\"url\" title=\"\">foo</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[foo]: /url \"title\" ok\n"
        html = "<p>[foo]: /url &quot;title&quot; ok</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[foo]: /url \"title\"\n"
        html = ""
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "# [Foo]\n[foo]: /url\n> bar\n"
        html = "<h1><a href=\"/url\" title=\"\">Foo</a></h1>\n<blockquote><p>bar</p>\n</blockquote>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Link and Image Imbrication
    #
    describe "Link and Image imbrication" do
      test "" do
        markdown = ""
        html = ""
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[[text](inner)]outer"
        html = "<p>[<a href=\"inner\">text</a>]outer</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[[text](inner)](outer)"
        html = "<p><a href=\"outer\">[text](inner)</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "![[text](inner)](outer)"
        html = "<p><img src=\"outer\" alt=\"[text](inner)\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[![moon](moon.jpg)](/uri)\n"
        html = "<p><a href=\"/uri\"><img src=\"moon.jpg\" alt=\"moon\"/></a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "![![moon](moon.jpg)](sun.jpg)\n"
        html = "<p><img src=\"sun.jpg\" alt=\"![moon](moon.jpg)\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Paragraphs
    #
    describe "Paragraphs" do
      test "" do
        markdown = "aaa\n\nbbb\n"
        html = "<p>aaa</p>\n<p>bbb</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "aaa\n\n\nbbb\n"
        html = "<p>aaa</p>\n<p>bbb</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Block Quotes
    #
    describe "Block Quotes" do
      test "" do
        markdown = "> Foo"
        html = "<blockquote><p>Foo</p>\n</blockquote>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "> # Foo\n> bar\n> baz\n"
        html = "<blockquote><h1>Foo</h1>\n<p>bar\nbaz</p>\n</blockquote>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "> bar\nbaz\n> foo\n"
        html = "<blockquote><p>bar\nbaz\nfoo</p>\n</blockquote>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "> - foo\n- bar\n"
        html = "<blockquote><ul>\n<li>foo\n</li>\n</ul>\n</blockquote>\n<ul>\n<li>bar\n</li>\n</ul>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # List Items
    #
    describe "List items" do
      test "" do
        markdown = "1.  A paragraph\n    with two lines.\n\n        indented code\n\n    > A block quote.\n"
        html = "<ol>\n<li><p>A paragraph\nwith two lines.</p>\n<pre><code>indented code</code></pre>\n<blockquote><p>A block quote.</p>\n</blockquote>\n</li>\n</ol>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "1.  space one\n\n1. space two"
        html = "<ol>\n<li><p>space one</p>\n</li>\n<li><p>space two</p>\n</li>\n</ol>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "- one\n\n two\n"
        html = "<ul>\n<li>one\n</li>\n</ul>\n<p> two</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "- one\n- two"
        html = "<ul>\n<li>one\n</li>\n<li>two\n</li>\n</ul>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "1. one\n1. two"
        html = "<ol>\n<li>one\n</li>\n<li>two\n</li>\n</ol>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "2. one\n3. two"
        html = "<ol start=\"2\">\n<li>one\n</li>\n<li>two\n</li>\n</ol>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "2. one"
        html = "<ol start=\"2\">\n<li>one\n</li>\n</ol>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "-one\n\n2.two\n"
        html = "<p>-one</p>\n<p>2.two</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "-1. not ok\n"
        html = "<p>-1. not ok</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "1. foo\nbar"
        html = "<ol>\n<li>foo\nbar\n</li>\n</ol>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "* a\n    b\nc"
        html = "<ul>\n<li>a\nb\nc\n</li>\n</ul>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "* x\n    a\n| A | B |"
        html = "<ul>\n<li>x\na\n| A | B |\n</li>\n</ul>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "* x\n | A | B |"
        html = "<ul>\n<li>x\n | A | B |\n</li>\n</ul>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Inlines
    #
    describe "Inlines" do
      test "" do
        markdown = "`hi`lo`\n"
        html = "<p><code class=\"inline\">hi</code>lo`</p>\n"
        messages = [[1, "Closing unclosed backquotes ` at end of input"]]
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "`a\nb`c\n"
        html = "<p><code class=\"inline\">a\nb</code>c</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "+ ``a `\n`\n b``c"
        html = "<ul>\n<li><code class=\"inline\">a `\n`\n b</code>c\n</li>\n</ul>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Backslash Escapes
    #
    describe "Backslash escapes" do
      test "" do
        markdown = "\\\\!\\\\\""
        html = "<p>\\!\\&quot;</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "\\`no code"
        html = "<p>`no code</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "\\\\` code`"
        html = "<p>\\<code class=\"inline\">code</code></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "\\\\ \\"
        html = "<p>\\ \\</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
        html = "<p>*not emphasized*\n[not a link](/foo)\n`not code`\n1. not a list\n* not a list\n# not a header\n[foo]: /url &quot;not a reference&quot;</p>\n"
        messages = [[3, "Closing unclosed backquotes ` at end of input"]]
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "\\\\*emphasis*\n"
        html = "<p>\\<em>emphasis</em></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Emphasis And Strong Emphasis
    #
    describe "Emphasis and strong emphasis" do
      test "" do
        markdown = "*foo bar*\n"
        html = "<p><em>foo bar</em></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "a*\"foo\"*\n"
        html = "<p>a<em>&quot;foo&quot;</em></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "_foo bar_\n"
        html = "<p><em>foo bar</em></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "_foo*\n"
        html = "<p>_foo*</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "_foo_bar_baz_\n"
        html = "<p><em>foo_bar_baz</em></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "**foo bar**\n"
        html = "<p><strong>foo bar</strong></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "foo**bar**\n"
        html = "<p>foo<strong>bar</strong></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "__foo bar__\n"
        html = "<p><strong>foo bar</strong></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "**foo__bar**\n"
        html = "<p><strong>foo__bar</strong></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "*(**foo**)*\n"
        html = "<p><em>(<strong>foo</strong>)</em></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "**(*foo*)**\n"
        html = "<p><strong>(<em>foo</em>)</strong></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "foo*\n"
        html = "<p>foo*</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Links
    #
    describe "Links" do
      test "" do
        markdown = "[link](/uri \"title\")\n"
        html = "<p><a href=\"/uri\" title=\"title\">link</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[link](/uri))\n"
        html = "<p><a href=\"/uri\">link</a>)</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[link]()\n"
        html = "<p><a href=\"\">link</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "[link](())\n"
        html = "<p><a href=\"()\">link</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Images
    #
    describe "Images" do
      test "" do
        markdown = "![foo](/url \"title\")\n"
        html = "<p><img src=\"/url\" alt=\"foo\" title=\"title\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "![foo](/url \"ti tle\")\n"
        html = "<p><img src=\"/url\" alt=\"foo\" title=\"ti tle\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "![foo](/url \"ti() tle\")\n"
        html = "<p><img src=\"/url\" alt=\"foo\" title=\"ti() tle\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "![f[]oo](/url \"ti() tle\")\n"
        html = "<p><img src=\"/url\" alt=\"f[]oo\" title=\"ti() tle\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "![foo[([])]](/url 'title')\n"
        html = "<p><img src=\"/url\" alt=\"foo[([])]\" title=\"title\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "![foo](/url no title)\n"
        html = "<p><img src=\"/url%20no%20title\" alt=\"foo\"/></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end

    #
    # Autolinks
    #
    describe "Autolinks" do
      test "" do
        markdown = "<http://foo.bar.baz>\n"
        html = "<p><a href=\"http://foo.bar.baz\">http://foo.bar.baz</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<irc://foo.bar:2233/baz>\n"
        html = "<p><a href=\"irc://foo.bar:2233/baz\">irc://foo.bar:2233/baz</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<mailto:foo@bar.baz>\n"
        html = "<p><a href=\"mailto:foo@bar.baz\">foo@bar.baz</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<foo@bar.example.com>\n"
        html = "<p><a href=\"mailto:foo@bar.example.com\">foo@bar.example.com</a></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "<>\n"
        html = "<p>&lt;&gt;</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
    end
    #
    # IAL
    #
    describe "IAL" do
      test "Not associated" do
        markdown = "{:hello=worldend
        html = "<p>{:hello=world}</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
        end
        test "Not associated and incorrect" do
        markdown = "{:helloend
         html = "<p>{:hello}</p>\n"
         messages = [[1, "Illegal attributes [\"hello\"] ignored in IAL"]]
         assert Earmark.as_html(markdown) == {html, messages}
    end
    test "Associated" do
      markdown = "Before\n{:hello=worldend
      html = "<p hello=\"world\">Before</p>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "Associated" do
      markdown = "Before\n{:hello=worldend
      html = "<p hello=\"world\">Before</p>\n<p>After</p>\n"
      messages = []
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "Associated and incorrect" do
      markdown = "Before\n{:helloend
      html = "<p>Before</p>\n"
      messages = [[2, "Illegal attributes [\"hello\"] ignored in IAL"]]
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "Associated and partly incorrect" do
      markdown = "Before\n{:hello title=worldend
      html = "<p title=\"world\">Before</p>\n"
      messages = [[2, "Illegal attributes [\"hello\"] ignored in IAL"]]
      assert Earmark.as_html(markdown) == {html, messages}
    end
    test "Associated and partly incorrect and shortcuts" do
      markdown = "Before\n{:#hello .alpha hello title=world .beta class=\"gamma\" title='class'end
      html = "<p class=\"gamma beta alpha\" id=\"hello\" title=\"class world\">Before</p>\n"
      messages = [[2, "Illegal attributes [\"hello\"] ignored in IAL"]]
      assert Earmark.as_html(markdown) == {html, messages}
    end
    end

    #
    # Etc.
    #
    describe "etc" do
      test "" do
        markdown = "`f&ouml;&ouml;`\n"
        html = "<p><code class=\"inline\">f&amp;ouml;&amp;ouml;</code></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "`foo`\n"
        html = "<p><code class=\"inline\">foo</code></p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown = "Multiple     spaces\n"
        html = "<p>Multiple     spaces</p>\n"
        messages = []
        assert Earmark.as_html(markdown) == {html, messages}
      end
      test "" do
        markdown ="A\nB\n="
        html = "<p>A\nB</p>\n<p></p>\n"
        messages = [[3, "Unexpected line ="]]
        assert Earmark.as_html(markdown) == {html, messages}
      end

    end
end
