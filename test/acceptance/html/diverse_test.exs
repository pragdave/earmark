defmodule Acceptance.Html.DiverseTest do
  use Support.AcceptanceTestCase


  describe "etc" do
    test "entiy" do
      markdown = "`f&ouml;&ouml;`\n"
      html     = "<p>\n<code class=\"inline\">f&amp;ouml;&amp;ouml;</code></p>\n"
    
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "spaec preserving" do
      markdown = "Multiple     spaces"
      html     = "<p>\nMultiple     spaces</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "syntax errors" do
      markdown = "A\nB\n="
      html     = "<p>\nA\nB</p>\n<p>\n</p>\n"
      messages = [{:warning, 3, "Unexpected line =" }]

      assert as_html(markdown) == {:error, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
