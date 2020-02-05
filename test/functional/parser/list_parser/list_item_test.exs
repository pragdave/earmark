defmodule Functional.Parser.ListParser.ListItemTest do
  use ExUnit.Case

  import Earmark.LineScanner, only: [scan_lines: 1]
  import Earmark.Parser.ListParser, only: [parse_list_item: 1]

  describe "simple list items, only one line" do
    
    test "ending with a ruler/thematic break" do
      lines = "- a\n---"
      item = parse_item(lines)

      assert item == ["a"]
    end

    test "ending with a ruler/thematic break even indented" do
      lines = "- a\n   ---"
      item = parse_item(lines)

      assert item == ["a"]
    end

    test "indent of following line too small" do
      lines = "- a\n * b"
      item = parse_item(lines)

      assert item == ["a"]
    end

  end

  describe "slurp in next line" do
    test "next line is indented enough to be part of the item" do
      lines = "- a\n  * b"
      item = parse_item(lines)

      assert item == ["a", "* b"]
    end
  end

  defp parse_item(lines) when is_binary(lines) do
    lines
    |> String.split("\n")
    |> parse_item()
  end
  defp parse_item(lines) do
    with {lines, _rest, _options} <-
      lines
      |> scan_lines()
      |> IO.inspect
      |> parse_list_item() do
        lines
      end
  end
  
end
