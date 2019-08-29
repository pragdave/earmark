defmodule Acceptance.Ast.InlineIalTest do
  use ExUnit.Case
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  @moduletag :ast

  describe "IAL no errors" do
    test "link with simple ial" do
      markdown = "[link](url){: .classy}"
      html = "<p><a class=\"classy\" href=\"url\">link</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "code with simple ial" do
      markdown = "`some code`{: .classy}"
      html = "<p><code class=\"inline classy\">some code</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "img with simple ial" do
      markdown = "![link](url){:#thatsme}"
      html = "<p><img alt=\"link\" id=\"thatsme\" src=\"url\" /></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "not attached" do
      markdown = "[link](url) {:lang=fr}"
      html = "<p><a href=\"url\" lang=\"fr\">link</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "Error Handling" do
    test "illegal format line one" do
      markdown = "[link](url){:incorrect}"
      html = "<p><a href=\"url\">link</a></p>\n"
      ast      = parse_html(html)
      messages = [{:warning, 1, "Illegal attributes [\"incorrect\"] ignored in IAL"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "illegal format line two" do
      markdown = "a line\n[link](url) {:incorrect x=y}"
      html = "<p>a line\n<a href=\"url\" x=\"y\">link</a></p>\n"
      ast      = parse_html(html)
      messages = [{:warning, 2, "Illegal attributes [\"incorrect\"] ignored in IAL"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
