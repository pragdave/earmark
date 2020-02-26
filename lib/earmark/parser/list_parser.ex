defmodule Earmark.Parser.ListParser do
  alias Earmark.Block
  alias Earmark.Line
  alias Earmark.Options
  alias Earmark.Parser.ListInfo

  import ListInfo, only: [update_pending: 2]

  import Earmark.Helpers.StringHelpers, only: [behead: 2]
  import Earmark.Helpers.LookaheadHelpers, only: [opens_inline_code: 1, still_inline_code: 2]
  import Earmark.Message, only: [add_message: 2]

  @moduledoc false

  @not_pending {nil, 0}

  defmodule Ctxt do
    @derive { Inspect, only: [:lines, :list_info] }

    defstruct(
      lines: [],
      list_info: %ListInfo{},
      options: %Options{}
    )
  end

  def parse_list(lines, result, options \\ %Options{}) do
    {items, rest, options1} = parse_list_items(lines, options)
    list                    = _make_list(items, _empty_list(items) )
    # lists                 = _make_lists(items1, [], list)
    # IO.inspect lists, label: "parsed lists"
    {[list|result], rest, options1}
  end

  def parse_list_items(input, options) do
    parse_list_items(:init, input, [], options)
  end

  defp parse_list_items(state, input, output, ctxt) do
    lnb = case input do
      [] -> "EOF"
      [%{lnb: lnb}|_] -> lnb
    end
    _debug {state, lnb, input, output, ctxt}
    _parse_list_items(state, input, output, ctxt)
  end

  defp _parse_list_items(state, input, output, ctxt)
  defp _parse_list_items(:init, [item|rest], list_items, options) do
    parse_list_items(:start, rest, _make_and_prepend_list_item(item, list_items), %Ctxt{lines: [item.content], list_info: ListInfo.new(item), options: options})
  end
  defp _parse_list_items(:end, rest, items, ctxt), do: {items, rest, ctxt.options}
  defp _parse_list_items(:start, rest, items, ctxt), do: _parse_list_items_start(rest, items, ctxt)
  defp _parse_list_items(:blank, rest, items, ctxt), do: _parse_list_items_blank(rest, items, ctxt)
  defp _parse_list_items(:spaced, rest, items, ctxt), do: _parse_list_items_spaced(rest, items, ctxt)

  defp _parse_list_items_blank(input, list_items, ctxt)
  defp _parse_list_items_blank([], list_items, ctxt), do: _finish_list_items([], list_items, true, ctxt)
  defp _parse_list_items_blank([%Line.Blank{}|rest], list_items, ctxt), do: parse_list_items(:blank, rest, list_items, _prepend_line(ctxt, ""))
  defp _parse_list_items_blank([%{indent: i}=line|rest], list_items, %{list_info: %{width: w}}=ctxt) when i >= w do
    parse_list_items(:blank, rest, list_items, _update_ctxt(ctxt, behead(line.line, w), line))
  end
  defp _parse_list_items_blank(input, list_items, ctxt), do: parse_list_items(:spaced, input, list_items, ctxt)

  defp _parse_list_items_spaced(input, items, ctxt)
  defp _parse_list_items_spaced(input, items, %{list_info: %{pending: @not_pending}}=ctxt) do
    _parse_list_items_spaced_np(input, items, ctxt)
  end
  defp _parse_list_items_spaced(input, items, ctxt) do
    _parse_list_items_spaced_pdg(input, items, ctxt)
  end

  defp _parse_list_items_spaced_np([%Line.Blank{}|rest], items, ctxt) do
    parse_list_items(:spaced, rest, items, ctxt)
  end
  defp _parse_list_items_spaced_np([%Line.Ruler{}|_]=lines, items, ctxt) do
    _finish_list_items(lines, items, false, ctxt)
  end
  defp _parse_list_items_spaced_np([%Line.ListItem{initial_indent: ii}=item|_]=input, list_items, %{list_info: %{width: w}}=ctxt)
    when ii < w do
      if _starts_list?(item, list_items) do
        _finish_list_items(input, list_items, false, ctxt)
      else
        {items1, options1} = _finish_list_item(list_items, false, ctxt)
        parse_list_items(:init, input, items1, options1)
      end
  end
  # TODO: Check if this branch is not redundant, maybe even bogus! -- probably not as we do not have the same indentation rules
  #                                                                   for list_items and other lines
  # BUG: Still do not know how much to indent here???
  defp _parse_list_items_spaced_np([%Line.ListItem{}=line|rest], items, ctxt) do
    indented = _behead_spaces(line.line, ctxt.list_info.width)
    parse_list_items(:spaced, rest, items, _update_ctxt(ctxt, indented, line))
  end
  # BUG: Still do not know how much to indent here???
  defp _parse_list_items_spaced_np([%{indent: indent, line: str_line}=line|rest], items, %{list_info: %{width: width}}=ctxt) when
    indent >= width
  do
    parse_list_items(:spaced, rest, items, _update_ctxt(ctxt, behead(str_line, width), line))
  end
  defp _parse_list_items_spaced_np(input, items, ctxt) do
    _finish_list_items(input ,items, false, ctxt)
  end

  defp _parse_list_items_spaced_pdg(input, items, ctxt)
  defp _parse_list_items_spaced_pdg([], items, %{list_info: %{pending: {pending, lnb}}}=ctxt) do
    options1 =
      add_message(ctxt.options, {:warning, lnb, "Closing unclosed backquotes #{pending} at end of input"})
    _finish_list_items([], items, false, %{ctxt| options: options1})
  end
  defp _parse_list_items_spaced_pdg([line|rest], items, ctxt) do
    indented = _behead_spaces(line.line, ctxt.list_info.width)
    parse_list_items(:spaced, rest, items, _update_ctxt(ctxt, indented, line))
  end


  defp _parse_list_items_start(input, list_items, ctxt)
  defp _parse_list_items_start(input, list_items, %{list_info: %{pending: @not_pending}}=ctxt) do
    _parse_list_items_start_np(input, list_items, ctxt)
  end
  defp _parse_list_items_start(input, list_items, ctxt) do
    _parse_list_items_start_pdg(input, list_items, ctxt)
  end

  defp _parse_list_items_start_np(input, list_items, ctxt)
  defp _parse_list_items_start_np([%Line.Blank{}|input], items, ctxt) do
    parse_list_items(:blank, input, items, _prepend_line(_set_spaced(ctxt), ""))
  end
  defp _parse_list_items_start_np([], list_items, ctxt) do
    _finish_list_items([], list_items, true, ctxt)
  end
  defp _parse_list_items_start_np([%Line.Ruler{}|_]=input, list_items, ctxt) do
    _finish_list_items(input, list_items, true, ctxt)
  end
  defp _parse_list_items_start_np([%Line.ListItem{initial_indent: ii}=item|rest]=input, list_items, %{list_info: %{indent: i, width: w}}=ctxt)
    when ii < w do
      if _starts_list?(item, list_items) do
        _finish_list_items(input, list_items, true, ctxt)
      else
        {items1, options1} = _finish_list_item(list_items, true, ctxt)
        parse_list_items(:init, input, items1, options1)
      end
  end
  # Slurp in everything else before a first blank line
  defp _parse_list_items_start_np([%{line: str_line}=line|rest], items, ctxt) do
    indented = _behead_spaces(str_line, ctxt.list_info.width)
    parse_list_items(:start, rest, items, _update_ctxt(ctxt, indented, line))
  end

  defp _parse_list_items_start_pdg(input, items, ctxt)
  defp _parse_list_items_start_pdg([], items, lines, %{list_info: %{pending: {pending, lnb}}, options: options}=ctxt) do
    options1 =
      add_message(options, {:warning, lnb, "Closing unclosed backquotes #{pending} at end of input"})
    _finish_list_items(lines, items, true, %{ctxt|options: options1})
  end
  defp _parse_list_items_start_pdg([line|rest], items, ctxt) do
    parse_list_items(:start, rest, items, _update_ctxt(ctxt, line.line, line))
  end

  defp _behead_spaces(str, len) do
    Regex.replace(~r/\A\s{1,#{len}}/, str, "")
  end

  # INLINE CANDIDATE
  defp _empty_list([%Block.ListItem{loose?: loose?, type: type}|_]) do
    %Block.List{loose?: loose?, type: type}
  end

  # INLINE CANDIDATE
  @start_number_rgx ~r{\A0*(\d+)\.}
  defp _extract_start(%{bullet: bullet}) do
    case Regex.run(@start_number_rgx, bullet) do
      nil -> ""
      [_, "1"] -> ""
      [_, start] -> ~s{ start="#{start}"}
    end
  end


  # INLINE CANDIDATE
  defp _finish_list(%Block.List{blocks: blocks}=list), do: %{list|blocks: Enum.reverse(blocks)}

  # INLINE CANDIDATE
  defp _finish_list_item([%Block.ListItem{}=item|items], at_start?, ctxt) do
    {blocks, _, options1} = ctxt.lines
                            |> Enum.reverse
                            # |> IO.inspect(label: "Into parser:")
                            |> Earmark.Parser.parse(ctxt.options, :list)
                            # |> IO.inspect(label: "Inner parse result")
                            # |> _maybe_remove_para(loose?)
    # loose1? = _is_loose(item.loose?, item.starts_list?, at_start?, items) |> IO.inspect || _loose_by_spaced(blocks, ctxt.list_info.spaced) |> IO.inspect
    # IO.inspect {item.loose?, item.starts_list?, at_start?, items}
    # loose1? = _loose_by_spaced(blocks, ctxt.list_info.spaced)
    {[%{item | blocks: blocks, loose?: false}|items], options1}
  end

  defp _finish_list_items(input, items, at_start?, ctxt) do
    {items1, options1} = _finish_list_item(items, at_start?, ctxt)
    parse_list_items(:end, input, items1, %{ctxt|options: options1})
  end

  # INLINE CANDIDATE
  defp _make_and_prepend_list_item(%Line.ListItem{bullet: bullet, lnb: lnb, type: type}=item, list_items) do
    [%Block.ListItem{bullet: bullet, lnb: lnb, spaced: false, type: type}|list_items]
  end

  defp _make_list(items, list)
  defp _make_list([%Block.ListItem{bullet: bullet, lnb: lnb, type: type}=item], %Block.List{blocks: blocks, loose?: loose?}=list) do
    %{list | blocks: [%{item | loose?: loose?}|list.blocks],
      bullet: bullet,
      lnb: lnb,
      start: _extract_start(item)}
  end

  # INLINE CANDIDATE
  defp _make_list([%Block.ListItem{}=item|rest], %Block.List{loose?: loose?}=list) do
   _make_list(rest, %{list | blocks: [%{item | loose?: loose?}|list.blocks]})
  end


  defp _prepend_item(%Block.List{blocks: [%{spaced: spaced}|_]=blocks, loose?: lloose}=list, %Block.ListItem{loose?: liloose}=item) do
    blocks1 = [item | blocks]
    loose   = lloose || liloose || spaced
    %{list | loose?: loose, blocks: blocks1}
  end

  # INLINE CANDIDATE
  defp _prepend_line(%Ctxt{lines: lines}=ctxt, line) do
    %{ctxt|lines: [line|lines]}
  end
  # INLINE CANDIDATE
  defp _part_of_list?(block_list, line_list_item)
  defp _part_of_list?(%Block.List{bullet: bullet1}, %Line.ListItem{bullet: bullet2}), do: String.last(bullet1) == String.last(bullet2)

  # INLINE CANDIDATE
  defp _prepend_to_list(%Block.List{blocks: blocks}=list, items), do: %{list | blocks: [items ++ blocks]}

  # INLINE CANDIDATE
  defp _reverse_items(%Block.List{blocks: blocks}=list), do: %{list | blocks: Enum.reverse(blocks)}

  # INLINE CANDIDATE
  defp _set_spaced(ctxt), do: %{ctxt|list_info: %{ctxt.list_info|spaced: true}}

  defp _starts_list?(line_list_item, list_items)
  defp _starts_list?(_item, []), do: true
  defp _starts_list?(%{bullet: bullet1}, [%Block.ListItem{bullet: bullet2}|_]) do
    String.last(bullet1) != String.last(bullet2)
  end


  defp _update_ctxt(ctxt, line, pending_line)
  defp _update_ctxt(ctxt, nil, pending_line), do: %{ctxt | list_info: _update_list_info(ctxt.list_info, pending_line)}
  defp _update_ctxt(ctxt, line, pending_line) do
    %{_prepend_line(ctxt, line) | list_info: _update_list_info(ctxt.list_info, pending_line)}
  end

  # INLINE CANDIDATE
  defp _update_list_info(%{pending: pending}=list_info, line) do
    pending1 = still_inline_code(line, pending)
    %{list_info | pending: pending1}
  end

  # TODO: REMOVE
  defp _debug(value) do
    if System.get_env("DEBUG") do
      IO.inspect value
    end
  end

end
