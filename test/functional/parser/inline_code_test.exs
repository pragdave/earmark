defmodule Parser.InlineCodeTest do
  use ExUnit.Case

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
    {result, _, _} = Parser.parse(lines)
    expected = [
      %Block.Para{attrs: nil, lines: lines, lnb: 1}
    ]
    assert result == expected
  end

  test "Multiline inline code is parsed correctly (getting rid of code inside code)" do
    lines = [ "\\`prefix`first",
      "     second \\`",
      " third` `suffix`"]
    {result, _, _} = Parser.parse(lines)
    expected = [
      %Block.Para{attrs: nil, lines: lines, lnb: 1}
    ]
    assert result == expected
  end

  test "Multiline inline code is parsed correctly using triple backtix (getting rid of code and list items)" do
    lines = [ "\\`prefix```first",
      "     second \\`",
      "+ third``` `fourth``",
      "     fifth`"]
    {result, _, _} = Parser.parse(lines)
    expected = [
      %Block.Para{attrs: nil, lines: lines, lnb: 1}
    ]
    assert result == expected
  end

  test "Multiline inline code is correctly interpreting included longer and shorter sequences of backtix" do
    lines = [ "`single `` ```",
      "` ``double ` ```",
      "     `` ```triple \\``` \\\\` `` ````",
      "```"]
    {result, _, _} = Parser.parse(lines)
    expected = [
      %Block.Para{attrs: nil, lines: lines, lnb: 1}
    ]
    assert result == expected
  end

  test "Even number of inline code" do
    {result, _, _} = Parser.parse([ "third` suffix`"])
    expected = [
      %Block.Para{attrs: nil, lines: ["third` suffix`"], lnb: 1}
    ]
    assert result == expected
  end

  test "Escapes and Backtix" do
    {result, _, _} = Parser.parse([ "\\\\` more \\\\\\`code\\\\`"])
    expected = [
      %Earmark.Block.Para{attrs: nil, lines: ["\\\\` more \\\\\\`code\\\\`"], lnb: 1}
    ]
    assert result == expected
  end

  test "Escapes and Backtix and Code" do
    {result, _, _} = Parser.parse([ "\\\\` more \\\\\\`code\\\\`","    Hello"])
    expected = [
      %Earmark.Block.Para{attrs: nil, lines: ["\\\\` more \\\\\\`code\\\\`"], lnb: 1},
      %Earmark.Block.Code{attrs: nil, language: nil, lines: ["Hello"], lnb: 2}
    ]
    assert result == expected
  end
  ##########################################################################################
  #  Lists
  ##########################################################################################
  defp assert_list_with(result, text_lines), do: assert_list_with(result, text_lines, type: :ul)
  defp assert_list_with(result, text_lines, [type: type]) do
    bullet = if type == :ul do
      "*"
    else
      "1."
    end
    assert result == [
      %Block.List{
        attrs: nil,
        blocks: [%Block.ListItem{ attrs: nil,
          blocks: [%Block.Para{attrs: nil, lines: text_lines, lnb: 1}],
          spaced: false,
          bullet: bullet,
          type: type, lnb: 1}],
        type: type, lnb: 1}]
  end

  defp parse_as_list [line | rest], pfx \\ "*" do
    Parser.parse [ "#{pfx} #{line}" | rest ]
  end

  test "Mutliline inline code in list is parsed correctly (getting rid of list items inside code)" do
    lines = [
      "\\`prefix`first",
      "* second \\`",
      " third` `suffix`"]
    {result, _, _} = parse_as_list(lines)
    assert_list_with result, lines
  end

  test "Mutliline inline code in list is parsed correctly (getting rid of code inside code)" do
    lines = [ "\\`prefix`first",
      "     second \\`",
      " third` `suffix`"]
    {result, _, _} = parse_as_list( lines )
    assert_list_with result, lines
  end

  test "Mutliline inline code in list is parsed correctly using triple beaktix (getting rid of code and list items)" do
    lines = [ "\\`prefix```first",
      "     second \\`",
      "+ third``` `fourth``",
      "     fifth`"]
    {result, _, _} = parse_as_list( lines )
    assert_list_with result, lines
  end

  test "Mutliline inline code in list is correctly interpreting included longer and shorter sequences of backtix" do
    lines = [ "`single `` ```",
      "` ``double ` ```",
      "     `` ```triple \\``` ` `` ````",
      "```"]
    {result, _, _} = parse_as_list( lines, "1." )
    assert_list_with result, lines, type: :ol
  end

  test "Mutliline inline code in list is correctly interpreting included escaped sequences of backtix" do
    lines = [ "`single `` ```",
      "` ``double ` ```",
      "     `` ```triple \\\\\\``` \\\\` `` ````",
      "```"]
    {result, _, _} = parse_as_list( lines, "1." )
    assert_list_with result, lines, type: :ol
  end

  test "Even number of inline code in list" do
    lines = [ "third` suffix`"]
    {result, _, _} = parse_as_list( lines, "1." )
    assert_list_with result, lines, type: :ol
  end
end
