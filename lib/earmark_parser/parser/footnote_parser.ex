defmodule Earmark.Parser.Parser.FootnoteParser do
  alias Earmark.Parser.{Block, Line}

  @moduledoc false

  def parse_fn_defs(input, result, options) do
    {fn_defs, doc_lines, footnotes, options1} = _collect_fn_defs(input, [], [], %{}, options)
    fn_list = %Block.FnList{blocks: Enum.reverse(fn_defs)}

    {doc_blocks, _doc_links, _inner_footnotes, options2} =
      Earmark.Parser.Parser.parse(doc_lines, options1, false)

    reversed_doc = Enum.reverse(doc_blocks)
    {[fn_list | reversed_doc] ++ result, footnotes, options2}
  end

  defp _collect_fn_defs([], fn_defs, doc_lines, footnotes, options) do
    {fn_defs, doc_lines, footnotes, options}
  end

  defp _collect_fn_defs([%Line.FnDef{} = fn_def | rest], fn_defs, doc_lines, footnotes, options) do
    {body_lines, remaining} = _split_fn_body(rest)

    {inner_blocks, _links, _inner_fns, options1} =
      Earmark.Parser.Parser.parse([fn_def.content | body_lines], options, true)

    closed_fn = %Block.FnDef{id: fn_def.id, lnb: fn_def.lnb, blocks: inner_blocks}
    footnotes1 = Map.put(footnotes, closed_fn.id, closed_fn)
    _collect_fn_defs(remaining, [closed_fn | fn_defs], doc_lines, footnotes1, options1)
  end

  defp _collect_fn_defs([line | rest], fn_defs, doc_lines, footnotes, options) do
    _collect_fn_defs(rest, fn_defs, doc_lines ++ [line.line], footnotes, options)
  end

  defp _split_fn_body(lines), do: _split_fn_body(lines, [], false)

  defp _split_fn_body([], body, _after_blank), do: {Enum.reverse(body), []}

  defp _split_fn_body([%Line.FnDef{} | _] = rest, body, _after_blank) do
    {Enum.reverse(body), rest}
  end

  defp _split_fn_body([%Line.Blank{} | rest], body, _after_blank) do
    _split_fn_body(rest, ["" | body], true)
  end

  defp _split_fn_body([line | rest], body, true) do
    if line.indent >= 4 do
      _split_fn_body(rest, [line.line | body], false)
    else
      {Enum.reverse(body), [line | rest]}
    end
  end

  defp _split_fn_body([line | rest], body, false) do
    _split_fn_body(rest, [line.line | body], false)
  end
end

#  SPDX-License-Identifier: Apache-2.0
