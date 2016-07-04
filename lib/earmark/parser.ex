defmodule Earmark.Parser do

  alias Earmark.Line
  alias Earmark.Block


  # TODO: fix any
  # 
  @spec parse(list(String.t), %Earmark.Options{}, boolean) :: {Block.ts(), %{}}
  def parse(text_lines), do: parse(text_lines, %Earmark.Options{}, false)

  def parse(text_lines, options = %Earmark.Options{}, recursive) do
    # add blank lines before and after
    [ "" | text_lines ++ [""] ]
    |> Line.scan_lines(options, recursive)
    |> Block.parse(Map.get(options, :file))
  end

  ################################################################
  # Traverse the block list and extract the footnote definitions #
  ################################################################

  # @spec handle_footnotes( Block.ts, %Earmark.Options{}, ( Block.ts,
  def handle_footnotes(blocks, options, map_func) do
    { footnotes, blocks } = Enum.partition(blocks, &footnote_def?/1)
    footnotes = map_func.(blocks, &find_footnote_links/1)
                |> List.flatten
                |> get_footnote_numbers(footnotes, options)
    blocks = create_footnote_blocks(blocks, footnotes)
    footnotes = map_func.(footnotes, &({&1.id, &1})) |> Enum.into(Map.new)
    { blocks, footnotes }
  end

  @spec footnote_def?( Block.t )::boolean
  defp footnote_def?(%Block.FnDef{}), do: true
  defp footnote_def?(_block), do: false

  @spec find_footnote_links(Block.t) :: list(String.t)
  defp find_footnote_links(%Block.Para{lines: lines}), do: Enum.flat_map(lines, &extract_footnote_links/1)
  defp find_footnote_links(_), do: []

  @spec extract_footnote_links(String.t) :: list(String.t)
  defp extract_footnote_links(line) do
    Regex.scan(~r{\[\^([^\]]+)\]}, line)
    |> Enum.map(&tl/1)
  end

  @spec get_footnote_numbers( list(String.t), Block.ts, %Earmark.Options{} ) :: Block.ts
  def get_footnote_numbers(refs, footnotes, options) do
    Enum.reduce(refs, [], fn(ref, list) ->
      case Enum.find(footnotes, &(&1.id == ref)) do
        note = %Block.FnDef{} -> number = length(list) + options.footnote_offset
                                 note = %Block.FnDef{ note | number: number }
                                 [ note | list ]
        _                     -> list # TODO inline footnotes
      end
    end)
  end

  @spec create_footnote_blocks(Block.ts, Block.ts) :: Block.ts
  defp create_footnote_blocks(blocks, []), do: blocks

  defp create_footnote_blocks(blocks, footnotes) do
    footnote_block = %Block.FnList{blocks: Enum.sort_by(footnotes, &(&1.number))}
    Enum.concat(blocks, [footnote_block])
  end

end
