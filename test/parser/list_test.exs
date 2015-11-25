defmodule Parser.ListTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Block

  test "Implicit List continuation" do
    {result, _} = Parser.parse( ["- alpha", "beta"] )
    expect = [
      %Block.List{attrs: nil,
        blocks: [%Block.ListItem{attrs: nil,
            blocks: [%Block.Para{attrs: nil, lines: ["alpha", "beta"]}],
            spaced: false, type: :ul}], type: :ul}]

    assert result == expect
  end
  test "Implicit List continuation with bar" do
    {result, _} = Parser.parse( ["- alpha", "beta | gamma"] )
    expect = [
      %Block.List{attrs: nil,
        blocks: [%Block.ListItem{attrs: nil,
            blocks: [%Block.Para{attrs: nil, lines: ["alpha", "beta | gamma"]}],
            spaced: false, type: :ul}], type: :ul}]

    assert result == expect
  end
  test "Implicit List continuations with bars" do
    {result, _} = Parser.parse( ["- alpha", "beta | gamma", "delta | epsilon"] )
    expect = [
      %Block.List{attrs: nil,
        blocks: [%Block.ListItem{attrs: nil,
            blocks: [%Block.Para{attrs: nil, lines: ["alpha", "beta | gamma", "delta | epsilon"]}],
            spaced: false, type: :ul}], type: :ul}]

    assert result == expect
  end
end
