defmodule TransformTest do
  use ExUnit.Case

  doctest Earmark.Transform, import: true
  import Earmark.Transform

  describe "annotations" do
    test "annotations" do
      markdown = ["A joke %% smile", "", "Charming %% in_love"]
      {:ok, result_, []} = markdown |> Earmark.Parser.as_ast(annotations: "%%")
      {result__, _} = result_ |> map_ast_with(nil, &add_smiley/2)
      final = result__ |> Earmark.Transform.transform()
      expected = "<p>\nA joke %% smile</p>\n<p>\nCharming %% in_love</p>\n"

      assert final == expected
    end

    defp add_smiley(node, acc)

    defp add_smiley({_, _, _, meta} = quad, _) do
      case Map.get(meta, :annotation) do
        nil -> {quad, nil}
        ann -> {quad, ann}
      end
    end

    defp add_smiley(text, nil), do: {text, nil}
    defp add_smiley(text, ann), do: {text <> ann, nil}
  end
end

#  SPDX-License-Identifier: Apache-2.0
