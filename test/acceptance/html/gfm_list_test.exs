defmodule Acceptance.Html.GfmListTest do
  use Support.AcceptanceTestCase

  import Support.Html1Helpers

  describe "Lists and ListItems according to https://github.com/github/cmark-gfm/tree/master/test" do
    test "List items #231" do
      markdown = "A paragraph\nwith two lines.\n\n    indented code\n\n> A block quote.\n"
      expected = parse_trimmed("<p>A paragraph\nwith two lines.</p>\n<pre><code>indented code\n</code></pre>\n<blockquote>\n<p>A block quote.</p>\n</blockquote>\n")

      assert to_html2(markdown) == expected
    end
    @tag :inner_loose
    test "List items #232" do
      markdown = "1.  A paragraph\n    with two lines.\n\n        indented code\n\n    > A block quote.\n"
      expected = parse_trimmed("<ol>\n<li>\n<p>A paragraph\nwith two lines.</p>\n<pre><code>indented code\n</code></pre>\n<blockquote>\n<p>A block quote.</p>\n</blockquote>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #233" do
      markdown = "- one\n\n two\n"
      expected = parse_trimmed("<ul>\n<li>one</li>\n</ul>\n<p>two</p>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #234" do
      markdown = "- one\n\n  two\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>one</p>\n<p>two</p>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #235" do
      markdown = " -    one\n\n     two\n"
      expected = parse_trimmed("<ul>\n<li>one</li>\n</ul>\n<pre><code> two\n</code></pre>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #236" do
      markdown = " -    one\n\n      two\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>one</p>\n<p>two</p>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #237" do
      markdown = "   > > 1.  one\n>>\n>>     two\n"
      expected = parse_trimmed("<blockquote>\n<blockquote>\n<ol>\n<li>\n<p>one</p>\n<p>two</p>\n</li>\n</ol>\n</blockquote>\n</blockquote>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #238" do
      markdown = ">>- one\n>>\n  >  > two\n"
      expected = parse_trimmed("<blockquote>\n<blockquote>\n<ul>\n<li>one</li>\n</ul>\n<p>two</p>\n</blockquote>\n</blockquote>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #239" do
      markdown = "-one\n\n2.two\n"
      expected = parse_trimmed("<p>-one</p>\n<p>2.two</p>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #240" do
      markdown = "- foo\n\n\n  bar\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>foo</p>\n<p>bar</p>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    # test "List items #241" do
    #   markdown = "1.  foo\n\n    ```\n    bar\n    ```\n\n    baz\n\n    > bam\n"
    #   expected = parse_trimmed("<ol>\n<li>\n<p>foo</p>\n<pre><code>bar\n</code></pre>\n<p>baz</p>\n<blockquote>\n<p>bam</p>\n</blockquote>\n</li>\n</ol>\n")

    #   assert to_html2(markdown) == expected
    # end
    test "List items #242" do
      markdown = "- Foo\n\n      bar\n\n\n      baz\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>Foo</p>\n<pre><code>bar\nbaz\n</code></pre>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #243" do
      markdown = "123456789. ok\n"
      expected = parse_trimmed("<ol start=\"123456789\">\n<li>ok</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #244" do
      markdown = "1234567890. not ok\n"
      expected = parse_trimmed("<p>1234567890. not ok</p>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #245" do
      markdown = "0. ok\n"
      expected = parse_trimmed("<ol start=\"0\">\n<li>ok</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #246" do
      markdown = "003. ok\n"
      expected = parse_trimmed("<ol start=\"3\">\n<li>ok</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #247" do
      markdown = "-1. not ok\n"
      expected = parse_trimmed("<p>-1. not ok</p>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #248" do
      markdown = "- foo\n\n      bar\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>foo</p>\n<pre><code>bar\n</code></pre>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #249" do
      markdown = "  10.  foo\n\n           bar\n"
      expected = parse_trimmed("<ol start=\"10\">\n<li>\n<p>foo</p>\n<pre><code>bar\n</code></pre>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #250" do
      markdown = "    indented code\n\nparagraph\n\n    more code\n"
      expected = parse_trimmed("<pre><code>indented code\n</code></pre>\n<p>paragraph</p>\n<pre><code>more code\n</code></pre>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #251" do
      markdown = "1.     indented code\n\n   paragraph\n\n       more code\n"
      expected = parse_trimmed("<ol>\n<li>\n<pre><code>indented code\n</code></pre>\n<p>paragraph</p>\n<pre><code>more code\n</code></pre>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #252" do
      markdown = "1.      indented code\n\n   paragraph\n\n       more code\n"
      expected = parse_trimmed("<ol>\n<li>\n<pre><code> indented code\n</code></pre>\n<p>paragraph</p>\n<pre><code>more code\n</code></pre>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #253" do
      markdown = "   foo\n\nbar\n"
      expected = parse_trimmed("<p>foo</p>\n<p>bar</p>\n")

      assert to_html2(markdown) == expected
    end
    @tag :wip
    test "List items #254" do
      markdown = "-    foo\n\n  bar\n"
      expected = parse_trimmed("<ul>\n<li>foo</li>\n</ul>\n<p>bar</p>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #255" do
      markdown = "-  foo\n\n   bar\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>foo</p>\n<p>bar</p>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    # test "List items #256" do
    #   markdown = "- \n  foo\n- \n  ```\n  bar\n  ```\n- \n      baz\n"
    #   expected = parse_trimmed("<ul>\n<li>foo</li>\n<li>\n<pre><code>bar\n</code></pre>\n</li>\n<li>\n<pre><code>baz\n</code></pre>\n</li>\n</ul>\n")

    #   assert to_html2(markdown) == expected
    # end
    test "List items #257" do
      markdown = "-   \n  foo\n"
      expected = parse_trimmed("<ul>\n<li>foo</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    @tag :wip
    test "List items #258" do
      markdown = "-\n\n  foo\n"
      expected = parse_trimmed("<ul>\n<li></li>\n</ul>\n<p>foo</p>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #260" do
      markdown = "- foo\n-   \n- bar\n"
      expected = parse_trimmed("<ul>\n<li>foo</li>\n<li></li>\n<li>bar</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #261" do
      markdown = "1. foo\n2. \n3. bar\n"
      expected = parse_trimmed("<ol>\n<li>foo</li>\n<li></li>\n<li>bar</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #263" do
      markdown = "foo\n*\n\nfoo\n1.\n"
      expected = parse_trimmed("<p>foo\n*</p>\n<p>foo\n1.</p>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #264" do
      markdown = " 1.  A paragraph\n     with two lines.\n\n         indented code\n\n     > A block quote.\n"
      expected = parse_trimmed("<ol>\n<li>\n<p>A paragraph\nwith two lines.</p>\n<pre><code>indented code\n</code></pre>\n<blockquote>\n<p>A block quote.</p>\n</blockquote>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #265" do
      markdown = "  1.  A paragraph\n      with two lines.\n\n          indented code\n\n      > A block quote.\n"
      expected = parse_trimmed("<ol>\n<li>\n<p>A paragraph\nwith two lines.</p>\n<pre><code>indented code\n</code></pre>\n<blockquote>\n<p>A block quote.</p>\n</blockquote>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #266" do
      markdown = "   1.  A paragraph\n       with two lines.\n\n           indented code\n\n       > A block quote.\n"
      expected = parse_trimmed("<ol>\n<li>\n<p>A paragraph\nwith two lines.</p>\n<pre><code>indented code\n</code></pre>\n<blockquote>\n<p>A block quote.</p>\n</blockquote>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #267" do
      markdown = "    1.  A paragraph\n        with two lines.\n\n            indented code\n\n        > A block quote.\n"
      expected = parse_trimmed("<pre><code>1.  A paragraph\n    with two lines.\n\n        indented code\n\n    &gt; A block quote.\n</code></pre>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #268" do
      markdown = "  1.  A paragraph\nwith two lines.\n\n          indented code\n\n      > A block quote.\n"
      expected = parse_trimmed("<ol>\n<li>\n<p>A paragraph\nwith two lines.</p>\n<pre><code>indented code\n</code></pre>\n<blockquote>\n<p>A block quote.</p>\n</blockquote>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #269" do
      markdown = "  1.  A paragraph\n    with two lines.\n"
      expected = parse_trimmed("<ol>\n<li>A paragraph\nwith two lines.</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #270" do
      markdown = "> 1. > Blockquote\ncontinued here.\n"
      expected = parse_trimmed("<blockquote>\n<ol>\n<li>\n<blockquote>\n<p>Blockquote\ncontinued here.</p>\n</blockquote>\n</li>\n</ol>\n</blockquote>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #271" do
      markdown = "> 1. > Blockquote\n> continued here.\n"
      expected = parse_trimmed("<blockquote>\n<ol>\n<li>\n<blockquote>\n<p>Blockquote\ncontinued here.</p>\n</blockquote>\n</li>\n</ol>\n</blockquote>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #272" do
      markdown = "- foo\n  - bar\n    - baz\n      - boo\n"
      expected = parse_trimmed("<ul>\n<li>foo\n<ul>\n<li>bar\n<ul>\n<li>baz\n<ul>\n<li>boo</li>\n</ul>\n</li>\n</ul>\n</li>\n</ul>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #273" do
      markdown = "- foo\n - bar\n  - baz\n   - boo\n"
      expected = parse_trimmed("<ul>\n<li>foo</li>\n<li>bar</li>\n<li>baz</li>\n<li>boo</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #274" do
      markdown = "10) foo\n    - bar\n"
      expected = parse_trimmed("<ol start=\"10\">\n<li>foo\n<ul>\n<li>bar</li>\n</ul>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #275" do
      markdown = "10) foo\n   - bar\n"
      expected = parse_trimmed("<ol start=\"10\">\n<li>foo</li>\n</ol>\n<ul>\n<li>bar</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #276" do
      markdown = "- - foo\n"
      expected = parse_trimmed("<ul>\n<li>\n<ul>\n<li>foo</li>\n</ul>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "List items #277" do
      markdown = "1. - 2. foo\n"
      expected = parse_trimmed("<ol>\n<li>\n<ul>\n<li>\n<ol start=\"2\">\n<li>foo</li>\n</ol>\n</li>\n</ul>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    @tag :wip
    test "List items #278" do
      markdown = "- # Foo\n- Bar\n  ---\n  baz\n"
      expected = parse_trimmed("<ul>\n<li>\n<h1>Foo</h1>\n</li>\n<li>\n<h2>Bar</h2>\nbaz</li>\n</ul>\n")

      assert to_html2(markdown) == [expected]
    end
    test "Lists #281" do
      markdown = "- foo\n- bar\n+ baz\n"
      expected = parse_trimmed("<ul>\n<li>foo</li>\n<li>bar</li>\n</ul>\n<ul>\n<li>baz</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #282" do
      markdown = "1. foo\n2. bar\n3) baz\n"
      expected = parse_trimmed("<ol>\n<li>foo</li>\n<li>bar</li>\n</ol>\n<ol start=\"3\">\n<li>baz</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #283" do
      markdown = "Foo\n- bar\n- baz\n"
      expected = parse_trimmed("<p>Foo</p>\n<ul>\n<li>bar</li>\n<li>baz</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    # test "Lists #284" do
    #   markdown = "The number of windows in my house is\n14.  The number of doors is 6.\n"
    #   expected = parse_trimmed("<p>The number of windows in my house is\n14.  The number of doors is 6.</p>\n")

    #   assert to_html2(markdown) == expected
    # end
    test "Lists #285" do
      markdown = "The number of windows in my house is\n1.  The number of doors is 6.\n"
      expected = parse_trimmed("<p>The number of windows in my house is</p>\n<ol>\n<li>The number of doors is 6.</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #286" do
      markdown = "- foo\n\n- bar\n\n\n- baz\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>foo</p>\n</li>\n<li>\n<p>bar</p>\n</li>\n<li>\n<p>baz</p>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    @tag :wip
    test "Lists #287" do
      markdown = "- foo\n  - bar\n    - baz\n\n\n      bim\n"
      expected = parse_trimmed("<ul>\n<li>foo\n<ul>\n<li>bar\n<ul>\n<li>\n<p>baz</p>\n<p>bim</p>\n</li>\n</ul>\n</li>\n</ul>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #288" do
      markdown = "- foo\n- bar\n\n<!-- -->\n\n- baz\n- bim\n"
      expected = parse_trimmed("<ul>\n<li>foo</li>\n<li>bar</li>\n</ul>\n<!-- -->\n<ul>\n<li>baz</li>\n<li>bim</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #289" do
      markdown = "-   foo\n\n    notcode\n\n-   foo\n\n<!-- -->\n\n    code\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>foo</p>\n<p>notcode</p>\n</li>\n<li>\n<p>foo</p>\n</li>\n</ul>\n<!-- -->\n<pre><code>code\n</code></pre>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #290" do
      markdown = "- a\n - b\n  - c\n   - d\n  - e\n - f\n- g\n"
      expected = parse_trimmed("<ul>\n<li>a</li>\n<li>b</li>\n<li>c</li>\n<li>d</li>\n<li>e</li>\n<li>f</li>\n<li>g</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #291" do
      markdown = "1. a\n\n  2. b\n\n   3. c\n"
      expected = parse_trimmed("<ol>\n<li>\n<p>a</p>\n</li>\n<li>\n<p>b</p>\n</li>\n<li>\n<p>c</p>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    # test "Lists #292" do
    #   markdown = "- a\n - b\n  - c\n   - d\n    - e\n"
    #   expected = parse_trimmed("<ul>\n<li>a</li>\n<li>b</li>\n<li>c</li>\n<li>d\n- e</li>\n</ul>\n")

    #   assert to_html2(markdown) == expected
    # end
    test "Lists #293" do
      markdown = "1. a\n\n  2. b\n\n    3. c\n"
      expected = parse_trimmed("<ol>\n<li>\n<p>a</p>\n</li>\n<li>\n<p>b</p>\n</li>\n</ol>\n<pre><code>3. c\n</code></pre>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #294" do
      markdown = "- a\n- b\n\n- c\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>a</p>\n</li>\n<li>\n<p>b</p>\n</li>\n<li>\n<p>c</p>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    # Priority: Low
    # test "Lists #295" do
    #   markdown = "* a\n*\n\n* c\n"
    #   expected = parse_trimmed("<ul>\n<li>\n<p>a</p>\n</li>\n<li></li>\n<li>\n<p>c</p>\n</li>\n</ul>\n")

    #   assert to_html2(markdown) == expected
    # end
    test "Lists #296" do
      markdown = "- a\n- b\n\n  c\n- d\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>a</p>\n</li>\n<li>\n<p>b</p>\n<p>c</p>\n</li>\n<li>\n<p>d</p>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #297" do
      markdown = "- a\n- b\n\n  [ref]: /url\n- d\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>a</p>\n</li>\n<li>\n<p>b</p>\n</li>\n<li>\n<p>d</p>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #298" do
      markdown = "- a\n- ```\n  b\n\n\n  ```\n- c\n"
      expected = parse_trimmed("<ul>\n<li>a</li>\n<li>\n<pre><code>b\n\n\n</code></pre>\n</li>\n<li>c</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    @tag :wip
    test "Lists #299" do
      markdown = "- a\n  - b\n\n    c\n- d\n"
      expected = parse_trimmed("<ul>\n<li>a\n<ul>\n<li>\n<p>b</p>\n<p>c</p>\n</li>\n</ul>\n</li>\n<li>d</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #300" do
      markdown = "* a\n  > b\n  >\n* c\n"
      expected = parse_trimmed("<ul>\n<li>a\n<blockquote>\n<p>b</p>\n</blockquote>\n</li>\n<li>c</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #301" do
      markdown = "- a\n  > b\n  ```\n  c\n  ```\n- d\n"
      expected = parse_trimmed("<ul>\n<li>a\n<blockquote>\n<p>b</p>\n</blockquote>\n<pre><code>c\n</code></pre>\n</li>\n<li>d</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #302" do
      markdown = "- a\n"
      expected = parse_trimmed("<ul>\n<li>a</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #303" do
      markdown = "- a\n  - b\n"
      expected = parse_trimmed("<ul>\n<li>a\n<ul>\n<li>b</li>\n</ul>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #304" do
      markdown = "1. ```\n   foo\n   ```\n\n   bar\n"
      expected = parse_trimmed("<ol>\n<li>\n<pre><code>foo\n</code></pre>\n<p>bar</p>\n</li>\n</ol>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #305" do
      markdown = "* foo\n  * bar\n\n  baz\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>foo</p>\n<ul>\n<li>bar</li>\n</ul>\n<p>baz</p>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end
    test "Lists #306" do
      markdown = "- a\n  - b\n  - c\n\n- d\n  - e\n  - f\n"
      expected = parse_trimmed("<ul>\n<li>\n<p>a</p>\n<ul>\n<li>b</li>\n<li>c</li>\n</ul>\n</li>\n<li>\n<p>d</p>\n<ul>\n<li>e</li>\n<li>f</li>\n</ul>\n</li>\n</ul>\n")

      assert to_html2(markdown) == expected
    end

    test "Additional From Babelmark #1001" do
      markdown = "- a\n* x\n* b\n\n2. c"
      expected = parse_trimmed( "<ul><li> a</li></ul><ul><li> x</li><li> b </li> </ul> <ol start=\"2\"> <li> c </li> </ol>")

      assert to_html2(markdown) == expected
    end

    test "Additional From Babelmark #1002" do
      markdown = "- a\n\n- b\n\n1. c"
      expected = parse_trimmed(" <ul> <li> <p> a </p> </li> <li> <p> b </p> </li> </ul> <ol> <li> c </li> </ol> ")

      assert to_html2(markdown) == expected
    end


  end

end
