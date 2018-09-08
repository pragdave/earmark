defmodule Earmark2.Acceptance.ScannerTest do
  use ExUnit.Case

  
  describe "text" do
    test "as easy as it gets" do
      assert scan(["hello world"]) == [{1, [{:text, "hello world", 1}]}]
    end
  end

  defp scan lines do
    lines |> Stream.zip(Stream.iterate(1,&(&1+1))) |> Enum.map(&Earmark2.Scanner.scan_line/1)
  end
end
