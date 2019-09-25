defmodule Acceptance.Html1.InlineIalTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "IAL no errors" do
    test "link with simple ial" do
      markdown = "[link](url){: .classy}"
      html     = para({:a, ~s{class="classy" href="url"}, "link"})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "code with simple ial" do
      markdown = "`some code`{: .classy}"
      html     = ~s{<p>\n<code class="inline classy">some code</code></p>\n}
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "img with simple ial" do
      markdown = "![link](url){:#thatsme}"
      html     = para({:img, ~s{alt="link" id="thatsme" src="url"}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    # A side effect, naay no more
    test "html and complex ial" do
      markdown = "<span xi=\"ypsilon\">{:alpha=beta .greek   }τι κανις</span>"
      html     = para("&lt;span xi=&quot;ypsilon&quot;&gt;{:alpha=beta .greek   }τι κανις&lt;/span&gt;")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "not attached" do
      markdown = "[link](url) {:lang=fr}"
      html     = para({:a, ~s{href="url" lang="fr"}, "link"})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "Error Handling" do
    test "illegal format line one" do
      markdown = "[link](url){:incorrect}"
      html     = para({:a, ~s{href="url"}, "link"})
      messages = [{:warning, 1, "Illegal attributes [\"incorrect\"] ignored in IAL"}]

      assert to_html1(markdown) == {:error, html, messages}
    end

    test "illegal format line two" do
      markdown = "a line\n[link](url) {:incorrect x=y}"
      html     = para([ "a line\n", {:a, ~s{href="url" x="y"}, "link"}])
      messages = [{:warning, 2, "Illegal attributes [\"incorrect\"] ignored in IAL"}]

      assert to_html1(markdown) == {:error, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
