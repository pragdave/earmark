defmodule TransformTest do
  use ExUnit.Case

  doctest Earmark.Transform, import: true
  import Earmark.Transform

  describe "annotations" do
    test "annotations" do
      markdown = [ "A joke %% smile", "", "Charming %% in_love" ]
      {:ok, result_, []} = markdown |> EarmarkParser.as_ast(annotations: "%%")
      {result__, _} = result_ |> map_ast_with(nil, &add_smiley/2)
      final = result__ |> Earmark.Transform.transform
      expected = "<p>\nA joke %% smile</p>\n<p>\nCharming %% in_love</p>\n"

      assert final == expected
    end

    defp add_smiley(node, acc)
    defp add_smiley({_, _, _, meta}=quad, _) do
      case Map.get(meta, :annotation) do
        nil -> {quad, nil}
        ann -> {quad, ann}
      end
    end
    defp add_smiley(text, nil), do: {text, nil}
    defp add_smiley(text, ann), do: {text <> ann, nil}
  end

  describe "structural modifications" do
    test "transformations can modify their children" do
      markdown = "## a caption"
      {:ok, ast, []} = markdown |> EarmarkParser.as_ast()
      rendered = ast
                 |> map_ast(&add_children/1)
                 |> Earmark.Transform.transform()

      expected = "<h2>\n<a href=\"#a-caption\">¶</a>a caption</h2>\n"
      assert rendered == expected
    end

    defp add_children({"h2", attrs, children, meta}) do
      {"h2", attrs, [{"a", [{"href", "#a-caption"}], ["¶"], %{}}|children], meta}
    end
    defp add_children(tuple_or_string), do: tuple_or_string
  end
end
#  SPDX-License-Identifier: Apache-2.0
