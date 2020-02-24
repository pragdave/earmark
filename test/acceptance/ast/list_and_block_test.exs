defmodule Acceptance.Ast.ListAndBlockTest do
  use ExUnit.Case
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  @moduletag :ast

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
  
end
# SPDX-License-Identifier: Apache-2.0
