defmodule Acceptance.Html1.IndentedCodeBlocksTest do
  use ExUnit.Case, async: true
  
  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Indented code blocks" do
    test "simple (but easy?)" do
      markdown = "    a simple\n      indented code block\n"
      html     = icode("a simple\n  indented code block")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "code is soo verbatim" do
      markdown = "    <a/>\n    *hi*\n\n    - one\n"
      html     = icode("&lt;a/&gt;\n*hi*\n\n- one")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "chunky bacon (RIP: Why)" do
      markdown = "    chunk1\n\n    chunk2\n  \n \n \n    chunk3\n"
      html     = icode("chunk1\n\nchunk2\n\n\n\nchunk3")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "foo and bar (now you are surprised!)" do
      markdown = "    foo\nbar\n"
      html     = construct([
        icode("foo"),
        {:p, nil, "bar"}
      ]) |> String.replace("\n\n", "\n")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "not the alpha, not the omega (gamma maybe?)" do
      markdown = "\n    \n    foo\n    \n\n"
      html     = icode("foo")
      messages = []
      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "Indented Code Blocks with IAL" do
    test "just an example" do
      markdown = "\n    wunderbar\n{: lang=\"de:at\"}\n"
      html     = ~s{<pre lang="de:at"><code>wunderbar</code></pre>\n}
      messages = []
      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
