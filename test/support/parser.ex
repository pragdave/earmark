defmodule Support.Parser do
  def parse_lines(lines) do
    Earmark.Parser.parse(%Earmark.Options{}, lines, false)
  end
end
