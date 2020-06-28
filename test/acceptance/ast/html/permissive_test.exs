defmodule Acceptance.Ast.Html.PermissiveTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  
  @verbatim %{verbatim: true}

  describe "some nesting" do
    test "simple case" do
      markdown = "<div>\ncontent\n </div>"
      ast      = [{"div", [], ["content"], @verbatim}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "more nesting" do
      markdown = "<div>\n<section>\n<span>content</span>\n</section>\n</div>"
      ast      = [{"div", [],
          ["<section>", "<span>content</span>", "</section>"], @verbatim}]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "arbitrary tags" do
    # Needs a fix with issue [#326](https://github.com/pragdave/earmark/issues/326)
    test "mixture of tags (was regtest #103)" do 
      markdown = "<x>a\n<y></y>\n<y>\n<z>\n</z>\n<z>\n</x>"
      ast      = [{"x", '', ["a", "<y></y>", "<y>", "<z>", "</z>", "<z>"], @verbatim}]
      messages = Enum.zip([1, 3, 6], ~w[x y z])
                 |> Enum.map(fn {lnb, tag} -> {:warning, lnb, "Failed to find closing <#{tag}>"} end)

      assert as_ast(markdown) == {:error, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0

