defmodule Acceptance.Ast.ListAndBlockTest do
  use ExUnit.Case
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import EarmarkAstDsl

  describe "Block Quotes in Lists" do
    # Incorrect behavior needs to be fixed with #249 or #304
    test "two spaces" do
      markdown = "- a\n  > b"
      html     = "<ul>\n<li>a<blockquote><p>b</p>\n</blockquote></li>\n</ul>\n"
      ast      = parse_html(html) # |> IO.inspect(label: :ast)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "four spaces" do
      markdown = "- c\n    > d"
      html     = "<ul>\n<li>c<blockquote><p>d</p>\n</blockquote>\n</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  # #349
  describe "Code Blocks in Lists" do
    @tag :wip 
    test "Regression #349" do
      markdown = """
      * List item1

        Text1

          * List item2

        Text2

            https://mydomain.org/user_or_team/repo_name/blob/master/path

      """
      ast = tag("ul", tag("li", [
        p("List item1"),
        p("Text1"),
        tag("pre", tag("code", ["* List item2"])),
        p("Text2"),
        tag("pre", tag("code", " https://mydomain.org/user_or_team/repo_name/blob/master/path"))]))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
    @tag :wip 
    test "Regression #349/counter example" do
      markdown = """
      * List item1

        Text1

          * List item2

        Text

            https://mydomain.org/user_or_team/repo_name/blob/master/path

      """
      ast = tag("ul", tag("li", [
        p("List item1"),
        tag("pre", tag("code", ["Text1", "", "* List item2", "", "Text2", "",
                                "https://mydomain.org/user_or_team/repo_name/blob/master/path"]))]))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
  
end
# SPDX-License-Identifier: Apache-2.0
