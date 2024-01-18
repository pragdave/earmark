defmodule Test.Acceptance.Transform.MapAstWithFnchangeTest do
  use ExUnit.Case

  import Earmark.Transform
  import EarmarkAstDsl

  describe "change #elixir" do
    @elixir_home {"a", [{"href", "https://elixir-lang.org"}], ["Elixir"], %{}}
    @original [
      {"p", [], ["#elixir"], %{}},
      {"bold", [], ["#elixir"], %{}},
      {"ol", [],
       [{"li", [], ["#elixir"], %{}}, {"p", [], ["elixir"], %{}}, {"p", [], ["#elixir"], %{}}],
       %{}}
    ]
    @expected [
      {"p", [], [{"a", [{"href", "https://elixir-lang.org"}], ["Elixir"], %{}}], %{}},
      {"bold", [], ["#elixir"], %{}},
      {"ol", [],
       [
         {"li", [], ["#elixir"], %{}},
         {"p", [], ["elixir"], %{}},
         {"p", [], [{"a", [{"href", "https://elixir-lang.org"}], ["Elixir"], %{}}], %{}}
       ], %{}}
    ]

    test "transform with function change" do
      result = map_ast(@original, &main_traverser/1)
      assert result == @expected
    end

    test "small" do
      ast = [p("#elixir"), p("hello")]
      expected = [p(@elixir_home), p("hello")]
      assert map_ast(ast, &main_traverser/1) == expected
    end

    defp main_traverser(element)

    defp main_traverser({"p", _, _, _} = para) do
      {&replacer/1, para}
    end

    defp main_traverser(element), do: element

    defp replacer(element)
    defp replacer("#elixir"), do: @elixir_home
    defp replacer(element) when is_binary(element), do: element
    defp replacer(element), do: {&main_traverser/1, element}
  end
end

# SPDX-License-Identifier: Apache-2.0
