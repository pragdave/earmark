defmodule ParseTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Block


  test "Heading at the start is interpreted correctly" do
    {result, _} = Parser.parse(["Heading", "=====", ""])
    assert result == [%Block.Heading{content: "Heading", level: 1}]
  end

  test "Heading at the end is interpreted correctly" do
    {result, _} = Parser.parse(["", "Heading", "====="])
    assert result == [%Block.Heading{content: "Heading", level: 1}]
  end

  test "Whitespace before and after code is ignored" do
    {result, _} = Parser.parse(["", 
      "    line 1",
      "    line 2",
      "",
      "",
      "para"])

    expect = [
      %Block.Code{attrs: nil, 
        language: nil,
        lines: ["line 1", "line 2"]},
      %Block.Para{attrs: nil, lines: ["para"]}
    ]
    assert result == expect
  end

  # test "Multiline inline code is parsed correctly" do
  #   {result, _} = Parser.parse([
  #     "prefix`first", 
  #     "* second",
  #     " third`suffix"])
  #   expect = [
  #     %Block.Para{attrs: nil, lines: ["prefix"]},
  #     %Block.Code{attrs: nil, lines: ["first", "* second", " third`"]},
  #     %Block.Para{attrs: nil, lines: ["suffix"]}
  #   ]
  #   assert result == expect
  # end

  test "Implicit List continuation" do
    {result, _} = Parser.parse( ["- alpha", "beta"] )
    expect = [
      %Earmark.Block.List{attrs: nil,
        blocks: [%Earmark.Block.ListItem{attrs: nil,
            blocks: [%Earmark.Block.Para{attrs: nil, lines: ["alpha", "beta"]}],
            spaced: false, type: :ul}], type: :ul}]

    assert result == expect
  end
  test "Implicit List continuation with bar" do
    {result, _} = Parser.parse( ["- alpha", "beta | gamma"] )
    expect = [
      %Earmark.Block.List{attrs: nil,
        blocks: [%Earmark.Block.ListItem{attrs: nil,
            blocks: [%Earmark.Block.Para{attrs: nil, lines: ["alpha", "beta | gamma"]}],
            spaced: false, type: :ul}], type: :ul}]

    assert result == expect
  end
  test "Implicit List continuations with bars" do
    {result, _} = Parser.parse( ["- alpha", "beta | gamma", "delta | epsilon"] )
    expect = [
      %Earmark.Block.List{attrs: nil,
        blocks: [%Earmark.Block.ListItem{attrs: nil,
            blocks: [%Earmark.Block.Para{attrs: nil, lines: ["alpha", "beta | gamma", "delta | epsilon"]}],
            spaced: false, type: :ul}], type: :ul}]

    assert result == expect
  end
end
