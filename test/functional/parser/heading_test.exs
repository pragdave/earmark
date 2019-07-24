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

  test "Start heading option is respected" do
    result = Earmark.as_html!("# test", %Earmark.Options{start_heading_level: 2})
    expected = "<h2>test</h2>\n"
    assert result == expected
  end

  test "Default start heading option is 1" do
    result = Earmark.as_html!("# test", %Earmark.Options{})
    expected = "<h1>test</h1>\n"
    assert result == expected
  end
end

# SPDX-License-Identifier: Apache-2.0
