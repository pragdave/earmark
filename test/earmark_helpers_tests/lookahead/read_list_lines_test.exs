defmodule EarmarkHelpersTests.Lookahead.ReadListLinesTest do
  use ExUnit.Case

  alias Earmark.Line
  import Earmark.Helpers.LookaheadHelpers, only: [read_list_lines: 3]

  test "read list lines for indent 4" do
    lines = [
      %Line.Indent{content: "- two", level: 1, line: "    - two", lnb: 2},
      %Line.Indent{content: "- three", level: 1, line: "    - three", lnb: 3}]

     result = read_list_lines(lines, {nil, 0}, 0)

     expected = {false, lines, [], 0, 4}

     assert result == expected
  end

  test "read list lines for indent 2" do
    lines = [
      %Line.ListItem{bullet: "-", content: "two", initial_indent: 2, line: "  - two", lnb: 2, type: :ul},
      %Line.ListItem{bullet: "-", content: "three", initial_indent: 2, line: "  - three", lnb: 3, type: :ul}]

     result = read_list_lines(lines, {nil, 0}, 0)

     expected = {false, lines, [], 0, 2}

     assert result == expected
  end

  test "read list lines for mixed indents" do
    lines = [
      %Line.ListItem{bullet: "-", content: "1.1", initial_indent: 2, line: "  - 1.1", lnb: 2, type: :ul},
      %Line.Indent{content: "  - 1.1.1", inside_code: false, level: 1, line: "      - 1.1.1", lnb: 3},
      %Line.ListItem{bullet: "-", content: "1.2", initial_indent: 3, line: "   - 1.2", lnb: 4, type: :ul}]

     result = read_list_lines(lines, {nil, 0}, 0)

     expected = {false, lines, [], 0, 2}

     assert result == expected
  end

  test "read list lines for level 4 indents" do
    lines = [
      %Line.Indent{content: "- 1.1", level: 1, line: "    - 1.1", lnb: 2},
      %Line.Indent{content: "- 1.1.1", level: 2, line: "        - 1.1.1", lnb: 3},
      %Line.Indent{content: " - 1.2", level: 1, line: "     - 1.2", lnb: 4}]

     result = read_list_lines(lines, {nil, 0}, 0)

     expected = {false, lines, [], 0, 4}

     assert result == expected
  end

  test "read list lines for many 4 level indents" do
    lines = [
      %Line.Indent{content: "- 1.1", inside_code: false, level: 1, line: "    - 1.1", lnb: 2},
      %Line.Indent{content: "- 1.1.1", inside_code: false, level: 2, line: "        - 1.1.1", lnb: 3},
      %Line.Indent{content: "- 1.2", inside_code: false, level: 1, line: "    - 1.2", lnb: 4}]

     result = read_list_lines(lines, {nil, 0}, 0)

     expected = {false, lines, [], 0, 4}

     assert result == expected
  end
end
