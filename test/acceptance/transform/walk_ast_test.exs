defmodule Test.Acceptance.Transform.WalkAstTest do
  use ExUnit.Case

  import Earmark.Transform, only: [map_ast_with: 4]

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
  end


  defp add_count({tag, atts, _, meta}, count) do
    {{tag, atts, nil, Map.put(meta, :count, count)}, count + 1}
  end

end
