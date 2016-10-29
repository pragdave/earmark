defmodule Parser.WhitespaceTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Block

  test "Whitespace before and after code is ignored" do
    {result, _, _} = Parser.parse(["",
      "    line 1",
      "    line 2",
      "",
      "",
      "para"])

    expected = [
      %Block.Code{attrs: nil,
        language: nil,
        lines: ["line 1", "line 2"]},
      %Block.Para{attrs: nil, lines: ["para"]}
    ]
    assert result == expected
  end
end

