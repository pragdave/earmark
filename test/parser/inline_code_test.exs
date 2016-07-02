defmodule Parser.InlineCodeTest do
  use ExUnit.Case

  use Kwfuns

  alias Earmark.Parser
  alias Earmark.Block

  ##########################################################################################
  #  Paragraphs
  ##########################################################################################
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

  test "Multiline inline code is parsed correctly using triple backtix (getting rid of code and list items)" do
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
      "     `` ```triple \\``` \\\\` `` ````",
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

  ##########################################################################################
  #  Lists
  ##########################################################################################
  # Need better macro skills to get default kw params
  defkwp assert_list_with result, text_lines, spaced: false, type: :ul do
    assert result == [
      %Block.List{
        attrs: nil,
        blocks: [%Block.ListItem{ attrs: nil,
          blocks: [%Block.Para{attrs: nil, lines: text_lines}],
          spaced: spaced,
          type: type}],
        type: type}]
  end

  defp parse_as_list [line | rest], pfx \\ "*" do
    Parser.parse [ "#{pfx} #{line}" | rest ]
  end

  test "Mutliline inline code in list is parsed correctly (getting rid of list items inside code)" do
    lines = [
      "\\`prefix`first",
      "* second \\`",
      " third` `suffix`"]
    {result, _} = parse_as_list(lines)
    assert_list_with result, lines
  end

  test "Mutliline inline code in list is parsed correctly (getting rid of code inside code)" do
    lines = [ "\\`prefix`first",
      "     second \\`",
      " third` `suffix`"]
    {result, _} = parse_as_list( lines )
    assert_list_with result, lines
  end

  test "Mutliline inline code in list is parsed correctly using triple beaktix (getting rid of code and list items)" do
    lines = [ "\\`prefix```first",
      "     second \\`",
      "+ third``` `fourth``",
      "     fifth`"]
    {result, _} = parse_as_list( lines )
    assert_list_with result, lines
  end

  test "Mutliline inline code in list is correctly interpreting included longer and shorter sequences of backtix" do
    lines = [ "`single `` ```",
      "` ``double ` ```",
      "     `` ```triple \\``` ` `` ````",
      "```"]
    {result, _} = parse_as_list( lines, "1." )
    assert_list_with result, lines, type: :ol
  end

  test "Mutliline inline code in list is correctly interpreting included escaped sequences of backtix" do
    lines = [ "`single `` ```",
      "` ``double ` ```",
      "     `` ```triple \\\\\\``` \\\\` `` ````",
      "```"]
    {result, _} = parse_as_list( lines, "1." )
    assert_list_with result, lines, type: :ol
  end

  test "Even number of inline code in list" do
    lines = [ "third` suffix`"]
    {result, _} = parse_as_list( lines, "1." )
    assert_list_with result, lines, type: :ol
  end
end
