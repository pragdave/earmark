defmodule Acceptance.Ast.AtxHeadersTest do
  use ExUnit.Case
  
  # describe "ATX headers" do

    test "from one to six" do
      markdown = "# foo\n## foo\n### foo\n#### foo\n##### foo\n###### foo\n"
      html     = "<h1>foo</h1>\n<h2>foo</h2>\n<h3>foo</h3>\n<h4>foo</h4>\n<h5>foo</h5>\n<h6>foo</h6>\n"
      ast      = Floki.parse(html) |> IO.inspect

      messages = []

      assert Earmark.as_ast(markdown) == {:ok, ast, messages}
    end

    test "seven? kidding, right?" do
      markdown = "####### foo\n"
      html     = "<p>####### foo</p>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "sticky (better than to have no glue)" do
      markdown = "#5 bolt\n\n#foobar\n"
      html     = "<p>#5 bolt</p>\n<p>#foobar</p>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "close escape" do
      markdown = "\\## foo\n"
      html     = "<p>## foo</p>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "position is so important" do
      markdown = "# foo *bar* \\*baz\\*\n"
      html     = "<h1>foo <em>bar</em> *baz*</h1>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "spacy" do
      markdown = "#                  foo                     \n"
      html     = "<h1>foo</h1>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "code comes first" do
      markdown = "    # foo\nnext"
      html     = "<pre><code># foo</code></pre>\n<p>next</p>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "some prefer to close their headers" do
      markdown = "# foo#\n"
      html     = "<h1>foo</h1>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "yes, they do (prefer closing their header)" do
      markdown = "### foo ### "
      html     = "<h3>foo ###</h3>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

  # end
end

# SPDX-License-Identifier: Apache-2.0
