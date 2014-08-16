defmodule ParseTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Block


  test "Heading at the start is interpreted correctly" do
    {result, _, _} = Parser.parse(["Heading", "=====", ""])
    assert result == [%Block.Heading{content: "Heading", level: 1}]
  end

  test "Heading at the end is interpreted correctly" do
    {result, _, _} = Parser.parse(["", "Heading", "====="])
    assert result == [%Block.Heading{content: "Heading", level: 1}]
  end

  test "Whitespace before and after code is ignored" do
    {result, _, _} = Parser.parse(["", 
                                "    line 1",
                                "    line 2",
                                "",
                                "",
                                "para"])

    expect = [
              %Earmark.Block.Code{attrs: nil, 
                                  language: nil,
                                  lines: ["line 1", "line 2"]},
              %Earmark.Block.Para{attrs: nil, lines: ["para"]}
             ]
    assert result == expect
  end

end
