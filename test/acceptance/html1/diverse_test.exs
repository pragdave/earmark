defmodule Acceptance.Html1.DiverseTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "etc" do
    test "entiy" do
      markdown = "`f&ouml;&ouml;`\n"
      html     = "<p>\n<code class=\"inline\">f&ouml;&ouml;</code></p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "space preserving" do
      markdown = "Multiple     spaces\n"
      html     = para("Multiple     spaces")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "syntax errors" do
      markdown ="A\nB\n="
      html     = "<p>\n  A\nB\n</p>\n<p></p>\n"
      messages = [{:warning, 3, "Unexpected line =" }]

      assert to_html1(markdown) == {:error, html, messages}
    end
   end

end

# SPDX-License-Identifier: Apache-2.0
