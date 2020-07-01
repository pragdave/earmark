defmodule Acceptance.Html.HorizontalRulesTest do
  use Support.AcceptanceTestCase
  describe "Horizontal rules" do

    test "thick, thin & medium" do
      markdown = "***\n---\n___\n"
      html     = "<hr class=\"thick\" />\n<hr class=\"thin\" />\n<hr class=\"medium\" />\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "not in code, second line" do
      markdown = "Foo\n    ***\n"
      html     = "<p>\nFoo</p>\n<pre><code>***</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "medium, long" do
      markdown = "_____________________________________\n"
      html     = "<hr class=\"medium\" />\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end

  describe "Horizontal Rules and IAL" do 
    test "add a class and an id" do
      markdown = "***\n{: .custom}\n---\n{: .klass #id42}\n___\n"
      html     = "<hr class=\"custom thick\" />\n<hr class=\"klass thin\" id=\"id42\" />\n<hr class=\"medium\" />\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}

    end
    
  end
end

# SPDX-License-Identifier: Apache-2.0
