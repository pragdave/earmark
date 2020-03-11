defmodule Acceptance.Ast.DiverseTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  describe "etc" do
    test "entiy" do
      markdown = "`f&ouml;&ouml;`\n"
      html     = "<p><code class=\"inline\">f&amp;ouml;&amp;ouml;</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "spaec preserving" do
      markdown = "Multiple     spaces\n"
      html     = "<p>Multiple     spaces</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "syntax errors" do
      markdown ="A\nB\n="
      html     = "<p>A\nB</p>\n<p></p>\n"
      ast      = parse_html(html)
      messages = [{:warning, 3, "Unexpected line =" }]

      assert as_ast(markdown) == {:error, ast, messages}
    end
   end

end

# SPDX-License-Identifier: Apache-2.0
