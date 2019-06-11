defmodule Earmark.Parser do
  alias Earmark.Block
  alias Earmark.Line
  alias Earmark.Options

  import Earmark.Message, only: [add_messages: 2]

  @doc """
  Given a markdown document (as either a list of lines or
  a string containing newlines), return a parse tree and
  the context necessary to render the tree.

  The options are a `%Earmark.Options{}` structure. See `as_html!`
  for more details.
  """
  def parse_markdown(lines, options \\ %Options{})
  def parse_markdown(lines, options = %Options{}) when is_list(lines) do
    {blocks, links, options1} = Earmark.Parser.parse(lines, options, false)

    context =
      %Earmark.Context{options: options1, links: links}
      |> Earmark.Context.update_context()

    if options.footnotes do
      {blocks, footnotes, options1} = handle_footnotes(blocks, context.options)
      context = put_in(context.footnotes, footnotes)
      context = put_in(context.options, options1)
      {blocks, context}
    else
      {blocks, context}
    end
  end
  def parse_markdown(lines, options) when is_binary(lines) do
    lines
    |> String.split(~r{\r\n?|\n})
    |> parse_markdown(options)
  end

  def parse(text_lines), do: parse(text_lines, %Options{}, false)
  def parse(text_lines, options = %Options{}, recursive) do
    ["" | text_lines ++ [""]]
    |> Line.scan_lines(options, recursive)
    |> Block.parse(options)
  end

  ################################################################
  # Traverse the block list and extract the footnote definitions #
  ################################################################

  # @spec handle_footnotes( Block.ts, %Earmark.Options{}, ( Block.ts,
  defp handle_footnotes(blocks, options) do
    {footnotes, blocks} = Enum.split_with(blocks, &footnote_def?/1)

    {footnotes, undefined_footnotes} =
      Options.get_mapper(options).(blocks, &find_footnote_links/1)
      |> List.flatten()
      |> get_footnote_numbers(footnotes, options)

    blocks = create_footnote_blocks(blocks, footnotes)
    footnotes = Options.get_mapper(options).(footnotes, &{&1.id, &1}) |> Enum.into(Map.new())
    options1 = add_messages(options, undefined_footnotes)
    {blocks, footnotes, options1}
  end

  defp footnote_def?(%Block.FnDef{}), do: true
  defp footnote_def?(_block), do: false

  defp find_footnote_links(%Block.Para{lines: lines, lnb: lnb}) do
    lines
    |> Enum.zip(Stream.iterate(lnb, &(&1 + 1)))
    |> Enum.flat_map(&extract_footnote_links/1)
  end

  defp find_footnote_links(%{blocks: blocks}) do
    Enum.flat_map(blocks, &find_footnote_links/1)
  end

  defp find_footnote_links(_), do: []

  defp extract_footnote_links({line, lnb}) do
    Regex.scan(~r{\[\^([^\]]+)\]}, line)
    |> Enum.map(&tl/1)
    |> Enum.zip(Stream.cycle([lnb]))
  end

  def get_footnote_numbers(refs, footnotes, options) do
    Enum.reduce(refs, {[], []}, fn {ref, lnb}, {defined, undefined} ->
      r = hd(ref)

      case Enum.find(footnotes, &(&1.id == r)) do
        note = %Block.FnDef{} ->
          number = length(defined) + options.footnote_offset
          note = %Block.FnDef{note | number: number}
          {[note | defined], undefined}

        _ ->
          {defined,
           [{:error, lnb, "footnote #{r} undefined, reference to it ignored"} | undefined]}
      end
    end)
  end

  defp create_footnote_blocks(blocks, []), do: blocks

  defp create_footnote_blocks(blocks, footnotes) do
    lnb =
      footnotes
      |> Stream.map(& &1.lnb)
      |> Enum.min()

    footnote_block = %Block.FnList{blocks: Enum.sort_by(footnotes, & &1.number), lnb: lnb}
    Enum.concat(blocks, [footnote_block])
  end
end

# SPDX-License-Identifier: Apache-2.0
