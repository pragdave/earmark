defmodule ListTest do
  use ExUnit.Case, async: true

  alias Earmark.Line
  alias Earmark.Block
  alias Earmark.Parser


  test "Indented Items (by 2)" do
    lines = [
      %Line.ListItem{bullet: "1.", content: "One", line: "1. One", lnb: 1, type: :ol},
      %Line.ListItem{bullet: "-", content: "two", initial_indent: 2, line: "  - two", lnb: 2, type: :ul},
      %Line.ListItem{bullet: "-", content: "three", initial_indent: 2, line: "  - three", lnb: 3, type: :ul} ]

     expected = { [%Block.List{attrs: nil,
           blocks: [%Block.ListItem{attrs: nil,
             blocks: [%Block.Para{attrs: nil, lines: ["One"],
               lnb: 1},
             %Block.List{attrs: nil,
              blocks: [%Block.ListItem{attrs: nil,
                blocks: [%Block.Para{attrs: nil, lines: ["two"],
                  lnb: 2}], bullet: "-", lnb: 2, spaced: false, type: :ul},
            %Block.ListItem{attrs: nil,
             blocks: [%Block.Para{attrs: nil, lines: ["three"],
               lnb: 3}], bullet: "-", lnb: 3, spaced: false,
           type: :ul}], lnb: 1, start: "", type: :ul}], bullet: "1.",
   lnb: 1, spaced: false, type: :ol}], lnb: 1, start: "", type: :ol}], options(3)}

  result = to_blocks(lines)
    assert result == expected
  end



  test "Basic UL" do
    result = lines_to_blocks([
      %Line.ListItem{type: :ul, bullet: "*", content: "line 1"}
    ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
        %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false, bullet: "*"}
      ]}], options()}
assert result == expected
  end



  test "UL containing two paras where the second is only indented 2 spaces" do
    result = lines_to_blocks([
      %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
      %Line.Blank{},
      %Line.Text{content: "  line 2", line: "  line 2"},
      %Line.Blank{}
    ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
        %Block.ListItem{blocks: [%Block.Para{lines: ["line 1"]},
          %Block.Para{lines: ["  line 2"], lnb: 2}],
         spaced: false, type: :ul, bullet: "*"}
     ]}], options()}
    assert result == expected
  end


  test "Two adjacent UL items, the first is not spaced" do
    result = lines_to_blocks([
      %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
      %Line.ListItem{type: :ul, bullet: "*", content: "line 2"},
    ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
        %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false, bullet: "*"},
        %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 2"]}], spaced: false, bullet: "*"},
      ]}], options()}
assert result == expected
  end

  test "Two UL items with a blank line between are both spaced" do
    result = lines_to_blocks([
      %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
      %Line.Blank{},
      %Line.ListItem{type: :ul, bullet: "*", content: "line 2"},
    ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
        %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: true, bullet: "*"},
        %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 2"]}], spaced: true, bullet: "*"},
      ]}], options()}
assert result == expected
  end

  test "Two UL items followed by a non-indented paragraph" do
    result = lines_to_blocks([
      %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
      %Line.ListItem{type: :ul, bullet: "*", content: "line 2"},
      %Line.Blank{},
      %Line.Text{content: "para", line: "para"}
    ], options())
    expected = {[
      %Block.List{ type: :ul, blocks: [
          %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false, bullet: "*"},
          %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 2"]}], spaced: false, bullet: "*"},
        ]},
      %Block.Para{lines: ["para"]},
    ], options()}
  assert result == expected
  end


  # OLs are handled by the same code as ULs, so to save time, we really just
  # need a single smoke test. If this changes in future, we'll need to
  # relook at this

  test "Basic OL" do
    result = lines_to_blocks([
      %Line.ListItem{type: :ol, bullet: "1.", content: "line 1"}
    ], options())
    expected = {[ %Block.List{ type: :ol, blocks: [
        %Block.ListItem{type: :ol, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false, bullet: "1."}
      ]}], options()}
assert result == expected
  end

  defp filename do
    "some file"
  end

  defp options(line \\ 0) do
    %Earmark.Options{file: filename(), line: line}
  end

  defp to_blocks(lines, line \\ 0) do
    lines_to_blocks(lines, options(line))
  end

  defp lines_to_blocks(lines, options) do
    {blks, _links, opts} = Parser.parse_lines(lines, options)
    {blks, opts}
  end

end

# SPDX-License-Identifier: Apache-2.0
