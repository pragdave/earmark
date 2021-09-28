defmodule TransformTest do
  use ExUnit.Case

  doctest Earmark.Transform, import: true

  describe "annotations" do
    test "annotations" do
      markdown = [ "A joke %% smile", "", "Charming %% in_love" ]
      add_smiley = fn {t, a, [c], m} = quad ->
                     case Map.get(m, :annotation) do
                       "%% smile"   -> {t, a, [[c, "\u1F601"] |> Enum.join(" ")], m}
                       "%% in_love" -> {t, a, [[c, "\u1F60d"] |> Enum.join(" ")], m}
                       _            -> {t, a, [c], m}
                     end
                   end
      result = Earmark.as_html!(markdown, annotations: "%%", postprocessor: Earmark.AstTools.node_only_fn(add_smiley))
      # result = Earmark.as_html!(markdown, annotations: "%%")
      expected = ""

      assert result == expected
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
