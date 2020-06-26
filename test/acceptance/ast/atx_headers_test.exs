defmodule Acceptance.Ast.AtxHeadersTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl
  
  describe "ATX headers" do

    test "from one to six" do
      markdown = "# foo\n## foo\n### foo\n#### foo\n##### foo\n###### foo\n"
      ast      = (1..6) |> Enum.map(&tag("h#{&1}", "foo"))
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "seven? kidding, right?" do
      markdown = "####### foo\n"
      ast      = p("####### foo")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "sticky (better than to have no glue)" do
      markdown = "#5 bolt\n\n#foobar\n"
      ast      = [ p("#5 bolt"), p("#foobar") ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "close escape" do
      markdown = "\\## foo\n"
      ast      = p("## foo")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "position is so important" do
      markdown = "# foo *bar* \\*baz\\*\n"
      ast      = tag("h1", ["foo ", tag("em", "bar"), " *baz*"])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "spacy" do
      markdown = "#                  foo                     \n"
      ast      = tag("h1", "foo")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "code comes first" do
      markdown = "    # foo\nnext"
      ast      = [pre_code("# foo"), p("next")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "some prefer to close their headers" do
      markdown = "# foo#\n"
      ast      = tag("h1", "foo")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "yes, they do (prefer closing their header)" do
      markdown = "### foo ### "
      ast      = tag("h3", "foo ###")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
