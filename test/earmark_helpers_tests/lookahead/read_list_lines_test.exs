defmodule EarmarkHelpersTests.Lookahead.ReadListLinesTest do
  use ExUnit.Case, async: true

  alias Earmark.Line
  import Earmark.Helpers.LookaheadHelpers, only: [read_list_lines: 3]
  import Earmark.LineScanner, only: [scan_lines: 1]

  describe "no list lines" do
    test "read list lines for indent 4" do
      lines = scan_lines([
        "    - two",
        "    - three" ])
      result = read_list_lines(lines, {nil, 0}, 0)
      expected = {false, lines, [], 0, 4}

      assert result == expected
    end

    test "read list lines for indent 2" do
      lines = scan_lines([
        "  - two",
        "  - three"])
      result = read_list_lines(lines, {nil, 0}, 0)
      expected = {false, lines, [], 0, 2}

      assert result == expected
    end

    test "read list lines for mixed indents" do
      lines = scan_lines([
        "  - 1.1",
        "      - 1.1.1",
        "   - 1.2"])
      result = read_list_lines(lines, {nil, 0}, 0)
      expected = {false, lines, [], 0, 2}

      assert result == expected
    end

    test "read list lines for level 4 indents" do
      lines = scan_lines([
        "    - 1.1",
        "        - 1.1.1",
        "     - 1.2"])
      result = read_list_lines(lines, {nil, 0}, 0)
      expected = {false, lines, [], 0, 4}

      assert result == expected
    end

    test "read list lines for many 4 level indents" do
      lines = scan_lines([
        "    - 1.1",
        "        - 1.1.1",
        "    - 1.2"])
      result = read_list_lines(lines, {nil, 0}, 0)
      expected = {false, lines, [], 0, 4}

      assert result == expected
    end
  end

  describe "continuations" do
    test "an empty line" do
      lines = scan("1. a\n\n  2. b\n\n    3. c")
      result = read_list_lines(lines, {nil, 0}, 0)
      expected = {false, lines, [], 0, 4}

      assert map(result) == [
        [Line.ListItem],
        [Line.ListItem],
        [Line.Indent],
      ]
    end
  end

  defp map {_, _, lines, _, _}, keys \\ [] do 
    lines
    |> Enum.map(&xtract(&1, keys))
  end

  defp scan string do
    string
    |> String.split("\n", trim: true)
    |> scan_lines()
  end

  defp xtract a_struct, keys do
    [ a_struct.__struct__ |
      Enum.map(keys, &Map.get(a_struct, &1))]
  end
end

# SPDX-License-Identifier: Apache-2.0
