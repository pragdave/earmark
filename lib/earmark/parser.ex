defmodule Earmark.Parser do

  alias Earmark.Line
  alias Earmark.Block


  def parse(text_lines, recursive \\ false) do
    Enum.map(text_lines, fn (line) -> Line.type_of(line, recursive) end)
    |> Block.parse
  end
  
end