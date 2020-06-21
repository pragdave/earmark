defmodule Acceptance.Ast.Html.OnelineTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  import Support.AstHelpers, only: [verb_tag: 2, verb_tag: 3]

  describe "oneline tags" do
    test "really simple" do
      markdown = "<h1>Headline</h1>"
      ast      = [verb_tag("h1", "Headline")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "a little bit more complicated" do
      markdown = ~s{<p align="center"><img src="image.svg"/></p>}
      ast      = [verb_tag("p", ["<img src=\"image.svg\"/>"], align: "center")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

