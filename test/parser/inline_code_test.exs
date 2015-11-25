defmodule Parser.InlineCodeTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Block

  test "Multiline inline code is parsed correctly (getting rid of list items inside code)" do
    lines = [
      "\\`prefix`first", 
      "* second \\`",
      " third` `suffix`"]
    {result, _} = Parser.parse(lines)
    expect = [
      %Block.Para{attrs: nil, lines: lines}
    ]
    assert result == expect
  end

  test "Multiline inline code is parsed correctly (getting rid of code inside code)" do
    lines = [ "\\`prefix`first", 
      "     second \\`",
      " third` `suffix`"]
    {result, _} = Parser.parse(lines)
    expect = [
      %Block.Para{attrs: nil, lines: lines}
    ]
    assert result == expect
  end

  test "Multiline inline code is parsed correctly using triple beaktix (getting rid of code and list items)" do
    lines = [ "\\`prefix```first", 
      "     second \\`",
      "+ third``` `fourth``",
      "     fifth`"]
    {result, _} = Parser.parse(lines)
    expect = [
      %Block.Para{attrs: nil, lines: lines}
    ]
    assert result == expect
  end

  test "Multiline inline code is correctly interpreting included longer and shorter sequences of backtix" do
    lines = [ "`single `` ```", 
      "` ``double ` ```",
      "     `` ```triple \\``` ` `` ````",
      "```"]
    {result, _} = Parser.parse(lines)
    expect = [
      %Block.Para{attrs: nil, lines: lines}
    ]
    assert result == expect
  end

  test "Even number of inline code" do
    {result, _} = Parser.parse([ "third` suffix`"])
    expect = [
      %Block.Para{attrs: nil, lines: ["third` suffix`"]}
    ]
    assert result == expect
  end
end
