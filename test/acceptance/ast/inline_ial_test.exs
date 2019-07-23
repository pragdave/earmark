defmodule Acceptance.InlineIalTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1]

  describe "IAL no errors" do
    test "link with simple ial" do
      markdown = "[link](url){: .classy}"
      html = "<p><a href=\"url\" class=\"classy\">link</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "code with simple ial" do
      markdown = "`some code`{: .classy}"
      html = "<p><code class=\"inline classy\">some code</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "img with simple ial" do
      markdown = "![link](url){:#thatsme}"
      html = "<p><img src=\"url\" alt=\"link\" id=\"thatsme\"/></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    # A side effect
    test "html and complex ial" do
      markdown = "<span xi=\"ypsilon\">{:alpha=beta .greek   }τι κανις</span>"
      html = "<p><span xi=\"ypsilon\" alpha=\"beta\" class=\"greek\">τι κανις</span></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "not attached" do
      markdown = "[link](url) {:lang=fr}"
      html = "<p><a href=\"url\" lang=\"fr\">link</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "Error Handling" do
    test "illegal format line one" do
      markdown = "[link](url){:incorrect}"
      html = "<p><a href=\"url\">link</a></p>\n"
      messages = [{:warning, 1, "Illegal attributes [\"incorrect\"] ignored in IAL"}]

      assert as_html(markdown) == {:error, html, messages}
    end

    test "illegal format line two" do
      markdown = "a line\n[link](url) {:incorrect x=y}"
      html = "<p>a line\n<a href=\"url\" x=\"y\">link</a></p>\n"
      messages = [{:warning, 2, "Illegal attributes [\"incorrect\"] ignored in IAL"}]

      assert as_html(markdown) == {:error, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
