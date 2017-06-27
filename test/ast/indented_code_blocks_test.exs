defmodule Acceptance.IndentedCodeBlocksTest do
  use ExUnit.Case
  
  # describe "Indented code blocks" do
    test "simple (but easy?)" do
      markdown = "    a simple\n      indented code block\n"
      # html     = "<pre><code>a simple\n  indented code block</code></pre>\n"
      ast = {"pre", [], [{"code", [], ["a simple\n  indented code block"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "code is soo verbatim" do
      markdown = "    <a/>\n    *hi*\n\n    - one\n"
      # html     = "<pre><code>&lt;a/&gt;\n*hi*\n\n- one</code></pre>\n"
      ast = {"pre", [], [{"code", [], ["&lt;a/&gt;*hi*\n\n- one"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "chunky bacon (RIP: Why)" do
      markdown = "    chunk1\n\n    chunk2\n  \n \n \n    chunk3\n"
      # html     = "<pre><code>chunk1\n\nchunk2\n\n\n\nchunk3</code></pre>\n"
      ast = {"pre", [], [{"code", [], ["chunk1\n\nchunk2\n\n\nchunk3"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "foo and bar (now you are surprised!)" do
      markdown = "    foo\nbar\n"
      # html     = "<pre><code>foo</code></pre>\n<p>bar</p>\n"
      ast = [{"pre", [], [{"code", [], ["foo"]}]}, {"p", [], ["bar"]}]
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "not the alpha, not the omega (gamma maybe?)" do
      markdown = "\n    \n    foo\n    \n\n"
      # html = "<pre><code>foo</code></pre>\n"
      ast = {"pre", [], [{"code", [], ["foo"]}]}
      messages = []
      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end
  # end
end
