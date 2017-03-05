defmodule Earmark.Parser do

  alias Earmark.Line
  alias Earmark.Block
  import Earmark.Global.Messages, only: [add_messages: 1]


  @spec parse(list(String.t), %Earmark.Options{}, boolean) :: {Block.ts(), %{}}
  def parse(text_lines), do: parse(text_lines, %Earmark.Options{}, false)

  def parse(text_lines, options = %Earmark.Options{}, recursive) do
    [ "" | text_lines ++ [""] ]
    |> Line.scan_lines(options, recursive)
    |> Block.parse(options)
  end

  ################################################################
  # Traverse the block list and extract the footnote definitions #
  ################################################################

  # @spec handle_footnotes( Block.ts, %Earmark.Options{}, ( Block.ts,
  def handle_footnotes(blocks, options, map_func) do
    { footnotes, blocks } = Enum.partition(blocks, &footnote_def?/1)
    { footnotes, undefined_footnotes } =
      map_func.(blocks, &find_footnote_links/1)
        |> List.flatten()
        |> get_footnote_numbers(footnotes, options)
    blocks = create_footnote_blocks(blocks, footnotes)
    footnotes = map_func.(footnotes, &({&1.id, &1})) |> Enum.into(Map.new)
    add_messages(undefined_footnotes)
    { blocks, footnotes }
  end

  @spec footnote_def?( Block.t )::boolean
  defp footnote_def?(%Block.FnDef{}), do: true
  defp footnote_def?(_block), do: false

  @spec find_footnote_links(Block.t) :: list(String.t)
  defp find_footnote_links(%Block.Para{lines: lines, lnb: lnb}) do
    lines
    |> Enum.zip(Stream.iterate(lnb, &(&1 + 1)))
    |> Enum.flat_map(&extract_footnote_links/1)
  end
  defp find_footnote_links(%{blocks: blocks}) do
    Enum.flat_map(blocks, &find_footnote_links/1)
  end
  defp find_footnote_links(_), do: []

  @spec extract_footnote_links({String.t, number()}) :: list({String.t, number()})
  defp extract_footnote_links({line, lnb}) do
    Regex.scan(~r{\[\^([^\]]+)\]}, line)
    |> Enum.map(&tl/1)
    |> Enum.zip(Stream.cycle([lnb]))
  end


  @spec get_footnote_numbers( list({String.t, number()} ), Block.ts, %Earmark.Options{} ) :: Block.ts
  def get_footnote_numbers(refs, footnotes, options) do
    Enum.reduce(refs, {[], []}, fn({ref, lnb}, {defined, undefined}) ->
      r = hd(ref)
      case Enum.find(footnotes, &(&1.id == r)) do
        note = %Block.FnDef{} -> number = length(defined) + options.footnote_offset
                                 note = %Block.FnDef{ note | number: number }
                                 {[ note | defined ], undefined}
        _                     -> {defined, [{:error, lnb, "footnote #{r} undefined, reference to it ignored"} | undefined]}
      end
    end)
  end

  @spec create_footnote_blocks(Block.ts, Block.ts) :: Block.ts
  defp create_footnote_blocks(blocks, []), do: blocks

  defp create_footnote_blocks(blocks, footnotes) do
    lnb = footnotes
      |> Stream.map(&(&1.lnb)) 
      |> Enum.min()
    footnote_block = %Block.FnList{blocks: Enum.sort_by(footnotes, &(&1.number)), lnb: lnb}
    Enum.concat(blocks, [footnote_block])
  end

end
