defmodule Earmark.Parser do

  alias Earmark.Line
  alias Earmark.Block


  def parse(lines) do
    lines |> Enum.map(&Line.type_of/1) |> Block.lines_to_blocks
  end
  
end