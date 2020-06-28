defmodule Acceptance.Ast.Html.OnelineTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl

  describe "oneline tags" do
    test "really simple" do
      markdown = "<h1>Headline</h1>"
      ast      = [vtag("h1", "Headline")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "a little bit more complicated" do
      markdown = ~s{<p align="center"><img src="image.svg"/></p>}
      ast      = [vtag("p", ["<img src=\"image.svg\"/>"], align: "center")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

