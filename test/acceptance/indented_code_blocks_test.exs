defmodule Acceptance.IndentedCodeBlocksTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_html: 1]

  # describe "Indented code blocks" do
    test "simple (but easy?)" do
      markdown = "    a simple\n      indented code block\n"
      html     = "<pre><code>a simple\n  indented code block</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "code is soo verbatim" do
      markdown = "    <a/>\n    *hi*\n\n    - one\n"
      html     = "<pre><code>&lt;a/&gt;\n*hi*\n\n- one</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "chunky bacon (RIP: Why)" do
      markdown = "    chunk1\n\n    chunk2\n  \n \n \n    chunk3\n"
      html     = "<pre><code>chunk1\n\nchunk2\n\n\n\nchunk3</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "foo and bar (now you are surprised!)" do
      markdown = "    foo\nbar\n"
      html     = "<pre><code>foo</code></pre>\n<p>bar</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "not the alpha, not the omega (gamma maybe?)" do
      markdown = "\n    \n    foo\n    \n\n"
      html = "<pre><code>foo</code></pre>\n"
      messages = []
      assert as_html(markdown) == {:ok, html, messages}
    end
  # end
end
