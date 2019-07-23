defmodule Acceptance.DiverseTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1]

  describe "etc" do
    test "entiy" do
      markdown = "`f&ouml;&ouml;`\n"
      html     = "<p><code class=\"inline\">f&amp;ouml;&amp;ouml;</code></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "spaec preserving" do
      markdown = "Multiple     spaces\n"
      html     = "<p>Multiple     spaces</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "syntax errors" do
      markdown ="A\nB\n="
      html     = "<p>A\nB</p>\n<p></p>\n"
      messages = [{:warning, 3, "Unexpected line =" }]

      assert as_html(markdown) == {:error, html, messages}
    end
   end

end

# SPDX-License-Identifier: Apache-2.0
