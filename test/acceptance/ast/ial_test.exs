defmodule Acceptance.Ast.IalTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import EarmarkAstDsl

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

    test "missing element for ial (was regtest #99)" do
      markdown = "{.hello}"
      ast      = p(markdown)
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

  describe "just text" do
    test "nothing to ial with" do
      markdown = "{:error, {IncompatibleUnitError, message}}"
      ast      = p("}")
      messages =
      [{:warning, 1, "Illegal attributes [\"message\", \"{IncompatibleUnitError,\", \"error,\"] ignored in IAL"}]

      assert as_ast(markdown) == {:error, [ast], messages }
    end

    test "nothing to ial with (inside list)" do
      markdown = "* {:error, {IncompatibleUnitError, message}}"
      ast      = tag("ul", tag("li", "}"))
      messages =
        [{:warning, 1, "Illegal attributes [\"message\", \"{IncompatibleUnitError,\", \"error,\"] ignored in IAL"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
