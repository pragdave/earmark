defmodule Parser.HeadingTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Block

  test "Heading at the start is interpreted correctly" do
    {result, _, _} = Parser.parse(["Heading", "=====", ""])
    assert result == [%Block.Heading{content: "Heading", level: 1, lnb: 1}]
  end

  test "Heading at the end is interpreted correctly" do
    {result, _, _} = Parser.parse(["", "Heading", "====="])
    assert result == [%Block.Heading{content: "Heading", level: 1, lnb: 2}]
  end

end
