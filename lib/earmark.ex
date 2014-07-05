defmodule Earmark do

  def to_html(lines, renderer \\ Earmark.HtmlRenderer)
  when is_list(lines) do
    lines
    |> Enum.map(&Earmark.Line.type_of/1)
    |> Earmark.Block.lines_to_blocks
    |> renderer.render
  end
end
