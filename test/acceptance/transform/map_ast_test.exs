defmodule Test.Acceptance.Transform.MapAstTest do
  use ExUnit.Case

  import Earmark.Transform
  import EarmarkAstDsl

  describe "adding a count" do
    @ast [
      {"h1", [], ["Head1"], %{}},
      {"ul", [],
       [
         {"li", [], [{"p", [], ["one"], %{}}], %{}},
         {"li", [],
          [
            {"p", [], ["two"], %{}},
            {"ul", [],
             [
               {"li", [], ["alpha"], %{}},
               {"li", [], ["beta"], %{}},
               {"li", [], [{"code", [{"class", "inline"}], ["gamma"], %{}}], %{}}
             ], %{}}
           ], %{}},
           {"li", [], [{"p", [], ["delta"], %{}}], %{}}
         ], %{}}
       ]
     @transformed [
       {"h1", [], ["Head1"], %{count: 0}},
       {"ul", [],
        [
          {"li", [], [{"p", [], ["one"], %{count: 3}}], %{count: 2}},
          {"li", [],
           [
             {"p", [], ["two"], %{count: 5}},
             {"ul", [],
              [
                {"li", [], ["alpha"], %{count: 7}},
                {"li", [], ["beta"], %{count: 8}},
                {"li", [], [{"code", [{"class", "inline"}], ["gamma"], %{count: 10}}], %{count: 9}}
              ], %{count: 6}}
            ], %{count: 4}},
            {"li", [], [{"p", [], ["delta"], %{count: 12}}], %{count: 11}}
          ], %{count: 1}}
        ]

    test "is easy" do
      {result, _} = map_ast_with(@ast, 0, &add_count/2, true)
      assert result == @transformed
    end

    defp add_count({tag, atts, _, meta}, count) do
      {{tag, atts, nil, Map.put(meta, :count, count)}, count + 1}
    end
  end

  describe "map_ast with change_content: true" do
    @list_ast [
      {"ul", [],
       [
         {"li", [], [{"p", [], ["Item 1"], %{}}], %{}},
         {"li", [], [{"p", [], ["Item 2"], %{}}], %{}}
       ], %{}}
     ]
    @lc_list_ast [
      {"ul", [],
       [
         {"li", [], [{"p", [], ["item 1"], %{}}], %{}},
         {"li", [], [{"p", [], ["item 2"], %{}}], %{}}
       ], %{}}
     ]
    test "lowercase content" do
      result = map_ast(@list_ast, &lowercase/1)
      assert result == @lc_list_ast
    end
    @annotated_ast [
      {"ul", [],
       [
         {"li", [], [{"p", [], ["Item 1"], %{annotation: "x1"}}], %{}},
         {"li", [], [{"p", [], ["Item 2"], %{annotation: "x2"}}], %{}}
       ], %{}}
     ]
    @transformed_annotated_ast [
      {"ul", [],
       [
         {"li", [], [{"p", [], ["Item 1x1"], %{annotation: "x1"}}], %{}},
         {"li", [], [{"p", [], ["Item 2x2"], %{annotation: "x2"}}], %{}}
       ], %{}}
     ]
     test "push annotation into node" do
      {result, _} = map_ast_with(@annotated_ast, nil, &push_annotation/2)
      assert result == @transformed_annotated_ast
     end

    defp lowercase(node)
    defp lowercase(quad) when is_tuple(quad), do: quad
    defp lowercase(text), do: String.downcase(text)

    defp push_annotation(node, acc)
    defp push_annotation({_, _, _, meta}=quad, _) do
      case Map.get(meta, :annotation) do
        nil  -> {quad, nil}
        anno -> {quad, anno}
      end
    end
    defp push_annotation(text, nil), do: {text, nil}
    defp push_annotation(text, anno), do: {text <> anno, nil}

  end

  describe "change content" do
    test "replace content of a node" do
      original = [div([p("x"), p("y")])]
      new = [div([div(p("x")), p("y")])]
      transformer = fn {"p", _, ["x"], _} = node -> {:replace, {"div", [], [node], %{}}}
                        other -> other end
      assert map_ast(original, transformer) == new
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
