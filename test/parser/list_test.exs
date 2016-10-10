defmodule Parser.ListTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Block

  test "Implicit List continuation" do
    expected = [
      %Block.List{attrs: nil,
        blocks: [%Block.ListItem{attrs: nil,
            blocks: [%Block.Para{attrs: nil, lines: ["alpha", "beta"]}],
            spaced: false, type: :ul}], type: :ul}]

    assert expected == parse( ["- alpha", "beta"] )
  end

  test "Implicit List continuation with bar" do
    expected = [
      %Block.List{attrs: nil,
        blocks: [%Block.ListItem{attrs: nil,
            blocks: [%Block.Para{attrs: nil, lines: ["alpha", "beta | gamma"]}],
            spaced: false, type: :ul}], type: :ul}]

    assert expected == parse( ["- alpha", "beta | gamma"] )
  end

  test "Implicit List continuations with bars" do
    expected = [
      %Block.List{attrs: nil,
        blocks: [%Block.ListItem{attrs: nil,
            blocks: [%Block.Para{attrs: nil, lines: ["alpha", "beta | gamma", "delta | epsilon"]}],
            spaced: false, type: :ul}], type: :ul}]

    assert expected == parse( ["- alpha", "beta | gamma", "delta | epsilon"] )
  end

  test "Spacing" do
    expected = [
      %Block.List{attrs: nil,
       blocks: [%Block.ListItem{attrs: nil,
         blocks: [%Block.Para{attrs: nil, lines: ["a"]}], spaced: true, type: :ul},
                 %Block.ListItem{attrs: nil, blocks: [
                   %Block.Para{attrs: nil, lines: ["b"]}], spaced: true, type: :ul}], type: :ul}]

     assert expected == parse( ["* a", "", "* b"] )
  end

  defp parse(lines) do
    with {result, _} <- Parser.parse(lines), do: result
  end
end
