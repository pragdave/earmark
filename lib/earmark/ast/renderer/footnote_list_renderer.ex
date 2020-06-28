defmodule Earmark.Ast.Renderer.FootnoteListRenderer do

  alias Earmark.Block
  import Earmark.Ast.Emitter

  @moduledoc false

  def render_footnote_list(items) do
    emit("div", [
      emit("hr"),
      emit("ol", _render_footnote_list_items(items))], class: "footnotes")
  end


  defp _render_footnote_list_items(items) do
    items
    |> Enum.map(&_render_footnote_list_item/1)
  end

  defp _render_footnote_list_item(%Block.ListItem{attrs: %{id: [id]}, blocks: [%Block.Para{attrs: atts, lines: lines}]}) do
    id1 = String.trim_leading(id, "#")
    emit("li", emit("p", lines ++ _render_footnote_backlink(atts)), id: id1)
  end

  defp _render_footnote_backlink(%{class: _, href: _, title: _}=atts) do
    [emit("a", "&#x21A9;", atts)]
  end


end
