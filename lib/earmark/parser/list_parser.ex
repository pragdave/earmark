defmodule Earmark.Parser.ListParser do
  alias Earmark.Block
  alias Earmark.Line
  alias Earmark.Options
  alias Earmark.Parser.ListInfo

  import Earmark.Helpers.StringHelpers, only: [behead: 2]
  import Earmark.Helpers.LookaheadHelpers, only: [opens_inline_code: 1, still_inline_code: 2]

  @moduledoc false

  @not_pending {nil, 0}

  def parse_list(lines, result, options \\ %Options{}) do
    {items, rest, options1} = parse_list_items(lines, result, options)
    {list, items1}          = _make_list(items)
    lists                   = _make_lists(items1, result, list)
    {lists, rest, options1}
  end

  def parse_list_items([item|rest], result, options) do
    IO.inspect rest
    _parse_list_items_start(rest, [_make_list_item(item)], [], ListInfo.new(item), options)
  end


  defp _parse_list_items_start(input, list_items, lines, list_info, options)
  # Toggle into state after start -> spaced
  defp _parse_list_items_start([%Line.Blank{}|input], items, lines, %{pending: @not_pending}=info, options),
    do: _parse_list_items_spaced(input, items, lines, info, options)
  # Check for end triggering lines
  defp _parse_list_items_start([], list_items, lines, _list_info, options) do
    # IO.inspect {2000, list_items}
    _finish_list_item(list_items, lines, [], true, options)
  end
  defp _parse_list_items_start([%Line.Ruler{}|rest], list_items, lines, _list_info, options) do
    # IO.inspect {2100, list_items}
    _finish_list_item(list_items, lines, rest, true, options)
  end
  # Do we look at the next list item here (we do not care if it is member of the same list here)
  defp _parse_list_items_start([%Line.ListItem{initial_indent: ii}|rest], list_items, lines, %{indent: i, pending: @not_pending}=info, options)
    when ii < i + 2 do
      # IO.inspect {2200, list_items}
      # BUG: Need to create a new list item, push it to items and continue
      _finish_list_item(list_items, lines, rest, true, options)
  end
  defp _parse_list_items_start([%Line.ListItem{}=line|rest], items, lines, %{pending: @not_pending}=info, options) do
    _parse_list_items_start(rest, items, [String.trim_leading(line.content)|lines], info, options)
  end
  # Slurp in everything else before a first blank line
  defp _parse_list_items_start([line|rest], items, lines, %{pending: @not_pending}=info, options) do
    IO.inspect {1400, line, lines}
    _parse_list_items_start(rest, items, [String.trim_leading(line.content)|lines], info, options)
  end
  # And for pending too
  defp _parse_list_items_start([line|rest], items, lines, %{pending: pending}=linfo, options) do
    linfo1 = _update_list_info(linfo, line)
    _parse_list_items_start(rest, items, [line.content|lines], linfo1, options)
  end

  defp _parse_list_items_spaced(input, items, lines, list_info, options)
  defp _parse_list_items_spaced([%Line.Ruler{}|rest], list_items, lines, _list_info, options) do
    _finish_list_item(items, lines, rest, false, options)
  end
  defp _parse_list_items_spaced([%Line.ListItem{initial_indent: ii}|rest], list_items, lines, %{indent: i, pending: @not_pending}, options)
    when ii < i + 2 do
      # IO.inspect {2200, list_items}
      list_items1 = _parse_content(list_items, lines)
      {item1, info1} = _make_list_item(item)
      _parse_list_items_start(rest, [item1|list_items1], [], info1, options)
  end
  defp _parse_list_items_spaced([%Line.ListItem{}=line|rest], items, lines, %{pending: @not_pending}=info, options) do
    _parse_list_items_spaced(rest, items, [String.trim_leading(line.content)|lines], info, options)
  end
  defp _parse_list_items_spaced([%{indent: indent, content: content}|rest], items, lines, %{pending: @not_pending, width: width}=info, options) when
    indent >= width
  do
    _parse_list_items_spaced
  end
  defp _parse_list_items_spaced(input, items, lines, list_info, options) do
    raise "SPACED Not Implemented Yet"
  end


  # INLINE CANDIDATE
  defp _finish_list(%Block.List{blocks: blocks}=list), do: %{list|blocks: Enum.reverse(blocks)}

  # INLINE CANDIDATE
  defp _finish_list_item([%Block.ListItem{loose?: loose?}=item|items], lines, rest, at_start?, options) do
    {blocks, _, options1} = Earmark.Parser.parse(lines, options, true)
    loose1? = loose? || !at_start?
    {[%{item | blocks: blocks, loose?: loose1?}|items], rest, options1}
  end

  # INLINE CANDIDATE
  defp _make_list_item(%Line.ListItem{bullet: bullet, lnb: lnb, type: type}=item) do
    { %Block.ListItem{bullet: bullet, lnb: lnb, type: type}, ListInfo.new(item) }
  end

  # INLINE CANDIDATE
  defp _make_list([%Block.ListItem{bullet: bullet, lnb: lnb, loose?: loose, type: type}=item|rest]) do
    {%Block.List{blocks: [item], bullet: bullet, lnb: lnb, loose?: loose, type: type}, rest}
  end

  defp _make_lists(items, result, list)
  defp _make_lists([], result, list), do: [_finish_list(list)|result]
  defp _make_lists([%Block.ListItem{starts_list?: true}|_]=items, result, list) do
    {list1, items1} = _make_list(items)
    _make_lists(items1, [_finish_list(list)|result], list1)
  end
  defp _make_lists([%Block.ListItem{}=item|items], result, list) do
    _make_lists(items, result, _prepend_item(list, item))
  end



  defp _prepend_item(%Block.List{blocks: [%{spaced?: spaced}|_]=blocks, loose?: lloose}=list, %Block.ListItem{loose?: liloose}=item) do
    blocks1 = [item | blocks]
    loose   = lloose || liloose || spaced
    %{list | loose?: loose, blocks: blocks1}
  end

  # INLINE CANDIDATE
  defp _part_of_list?(block_list, line_list_item)
  defp _part_of_list?(%Block.List{bullet: bullet1}, %Line.ListItem{bullet: bullet2}), do: bullet1 == bullet2

  # INLINE CANDIDATE
  defp _prepend_to_list(%Block.List{blocks: blocks}=list, items), do: %{list | blocks: [items ++ blocks]}

  # INLINE CANDIDATE
  defp _reverse_items(%Block.List{blocks: blocks}=list), do: %{list | blocks: Enum.reverse(blocks)}

  # INLINE CANDIDATE
  defp _update_list_info(%{pending: pending}=list_info, line) do
    pending1 = still_inline_code(line, pending)
    %{list_info | pending: pending1}
  end


  defp _show(anything)
  defp _show(x) when is_binary(x), do: x
  defp _show(%{__struct__: strct, blocks: nil}), do: "<#{strct} []>"
  defp _show(%{__struct__: strct, blocks: blocks}), do: "<#{strct} #{Enum.map(blocks, &_show/1)|> Enum.join(", ")}>"
  defp _show(%{__struct__: strct, line: line}), do: "<#{strct} #{line}>"
  defp _show(%{__struct__: strct}), do: "<#{strct} ...>"
  defp _show(x) when is_list(x), do: "[ #{Enum.map(x, &_show/1)|> Enum.join(", ")} ]"
end
