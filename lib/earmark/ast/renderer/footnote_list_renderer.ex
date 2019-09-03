defmodule Earmark.Ast.Renderer.FootnoteListRenderer do

  alias Earmark.Block

  import Earmark.Helpers.AstHelpers, only: [merge_attrs: 1]

  @moduledoc false

  def render_footnote_list(items) do
    { "div", [{"class", "footnotes"}], [
      {"hr", [], []},
      {"ol", [], _render_footnote_list_items(items)}] }
  end


  defp _render_footnote_list_items(items) do
    items
    |> Enum.map(&_render_footnote_list_item/1)
  end

  defp _render_footnote_list_item(%Block.ListItem{attrs: %{id: [id]}, blocks: [%Block.Para{attrs: atts, lines: lines}]}) do
    id1 = String.trim_leading(id, "#")
    {"li", [{"id", id1}],
      [{"p", [], lines ++ _render_footnote_backlink(atts)}]}
  end

  defp _render_footnote_backlink(%{class: _, href: _, title: _}=atts) do
    [{"a", merge_attrs(atts), ["\u21a9"]}]
  end


end
