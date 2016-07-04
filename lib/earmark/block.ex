defmodule Earmark.Block do

  use Earmark.Types
  import Earmark.Helpers, only: [emit_error: 4]
  import Earmark.Helpers.LookaheadHelpers, only: [opens_inline_code: 1, still_inline_code: 2, read_list_lines: 2]
  import Earmark.Helpers.LineHelpers

  @moduledoc """
  Given a list of _parsed blocks, convert them into blocks.
  That list of blocks is the final representation of the
  document (in internal form).
  """

  alias Earmark.Line
  alias Earmark.Parser


  defmodule Heading,     do: defstruct attrs: nil, content: nil, level: nil
  defmodule Ruler,       do: defstruct attrs: nil, type: nil
  defmodule BlockQuote,  do: defstruct attrs: nil, blocks: []
  defmodule List,        do: defstruct attrs: nil, type: :ul, blocks:  []
  defmodule ListItem,    do: defstruct attrs: nil, type: :ul, spaced: true, blocks: []
  defmodule Para,        do: defstruct attrs: nil, lines:  []
  defmodule Code,        do: defstruct attrs: nil, lines:  [], language: nil
  defmodule Html,        do: defstruct attrs: nil, html:   [], tag: nil
  defmodule HtmlOther,   do: defstruct attrs: nil, html:   []
  defmodule IdDef,       do: defstruct attrs: nil, id: nil, url: nil, title: nil
  defmodule FnDef,       do: defstruct attrs: nil, id: nil, number: nil, blocks: []
  defmodule FnList,      do: defstruct attrs: ".footnotes", blocks: []
  defmodule Ial,         do: defstruct attrs: nil

  defmodule Table do
    defstruct attrs: nil, rows: [], header: nil, alignments: []

    def new_for_columns(n) do
      %__MODULE__{alignments: Elixir.List.duplicate(:left, n)}
    end
  end

  @type t :: %Heading{} | %Ruler{} | %BlockQuote{} | %List{} | %ListItem{} | %Para{} | %Code{} | %Html{} | %HtmlOther{} | %IdDef{} | %FnDef{} | %FnList{} | %Ial{} | %Table{}
  @type ts :: list(t)

  @doc false
  # Given a list of `Line.xxx` structs, group them into related blocks.
  # Then extract any id definitions, and build a hashdict from them. Not
  # for external consumption.

  @spec parse( Line.ts, String.t ) :: {ts, %{}}
  def parse(lines, filename) do
    lines = remove_trailing_blank_lines( lines )
    blocks = lines_to_blocks(lines,filename)
    links  = links_from_blocks(blocks)
    { blocks, links }
  end

  @doc false
  # Public to allow easier testing
  def lines_to_blocks(lines,filename) do
    lines
    |> _parse([], filename)
    |> assign_attributes_to_blocks([])
    |> consolidate_list_items([])
  end


  @spec _parse(Line.ts, ts, String.t) :: ts
  defp _parse([], result, _filename), do: result

  ###################
  # setext headings #
  ###################

  defp _parse([  %Line.Blank{},
                %Line.Text{content: heading},
                %Line.SetextUnderlineHeading{level: level}

             |
                rest
             ], result, filename) do

    _parse(rest, [ %Heading{content: heading, level: level} | result ], filename)
  end

  defp _parse([  %Line.Blank{},
                %Line.Text{content: heading},
                %Line.Ruler{type: "-"}
             |
                rest
             ], result, filename) do

    _parse(rest, [ %Heading{content: heading, level: 2} | result ], filename)
  end

  #################
  # Other heading #
  #################

  defp _parse([ %Line.Heading{content: content, level: level} | rest ], result, filename) do
    _parse(rest, [ %Heading{content: content, level: level} | result ], filename)
  end

  #########
  # Ruler #
  #########

  defp _parse([ %Line.Ruler{type: type} | rest], result, filename) do
    _parse(rest, [ %Ruler{type: type} | result ], filename)
  end

  ###############
  # Block Quote #
  ###############

  defp _parse( lines = [ %Line.BlockQuote{} | _ ], result, filename) do
    {quote_lines, rest} = Enum.split_while(lines, &blockquote_or_text?/1)
    lines = for line <- quote_lines, do: line.content
    {blocks, _} = Parser.parse(lines, %Earmark.Options{}, true)
    _parse(rest, [ %BlockQuote{blocks: blocks} | result ], filename)
  end

  #########
  # Table #
  #########

  defp _parse( lines = [ %Line.TableLine{columns: cols1},
                        %Line.TableLine{columns: cols2}
                      | _rest
                      ], result, filename)
  when length(cols1) == length(cols2)
  do
    columns = length(cols1)
    { table, rest } = read_table(lines, columns, Table.new_for_columns(columns))
    _parse(rest, [ table | result ], filename)
  end

  #############
  # Paragraph #
  #############

  defp _parse( lines = [ %Line.TableLine{} | _ ], result, filename) do
    {para_lines, rest} = Enum.split_while(lines, &text?/1)
    line_text = (for line <- para_lines, do: line.line)
    _parse(rest, [ %Para{lines: line_text} | result ], filename)
  end

  defp _parse( lines = [ %Line.Text{} | _ ], result, filename)
  do
    {reversed_para_lines, rest, pending} = consolidate_para(lines)
    case pending do
      {nil, _} -> true
      {pending, lnb} ->
        emit_error filename, lnb, :warning, "Closing unclosed backquotes #{pending} at end of input"
    end
    line_text = (for line <- (reversed_para_lines |> Enum.reverse), do: line.line)
    _parse(rest, [ %Para{lines: line_text} | result ], filename)
  end

  #########
  # Lists #
  #########
  # We handle lists in two passes. In the first, we build list items,
  # in the second we combine adjacent items into lists. This is pass one

  defp _parse( [first = %Line.ListItem{type: type} | rest ], result, filename) do
    {spaced, list_lines, rest, offset} =
      case read_list_lines(rest, opens_inline_code(first)) do
        {s, ll, r, {_btx, lnb}} ->
          # emit_error filename, lnb, :warning, "Closing unclosed backquotes #{pending_btx} at end of input"
          {s, ll, r, lnb}
        {s, ll, r} -> {s, ll, r, 0}
      end

    spaced = (spaced || blank_line_in?(list_lines)) && peek(rest, Line.ListItem, type)
    lines = for line <- [first | list_lines], do: properly_indent(line, 1)
    {blocks, _} = Parser.parse(lines, %Earmark.Options{file: filename, line: offset}, true)

    _parse(rest, [ %ListItem{type: type, blocks: blocks, spaced: spaced} | result ], filename)
  end

  #################
  # Indented code #
  #################

  defp _parse( list = [%Line.Indent{} | _], result, filename) do
    {code_lines, rest} = Enum.split_while(list, &indent_or_blank?/1)
    code_lines = remove_trailing_blank_lines(code_lines)
    code = (for line <- code_lines, do: properly_indent(line, 1))
    _parse(rest, [ %Code{lines: code} | result ], filename)
  end

  ###############
  # Fenced code #
  ###############

  defp _parse([%Line.Fence{delimiter: delimiter, language: language} | rest], result, filename) do
    {code_lines, rest} = Enum.split_while(rest, fn (line) ->
      !match?(%Line.Fence{delimiter: ^delimiter, language: _}, line)
    end)
    rest = if length(rest) == 0, do: rest, else: tl(rest)
    code = (for line <- code_lines, do: line.line)
    _parse(rest, [ %Code{lines: code, language: language} | result ], filename)
  end

  ##############
  # HTML block #
  ##############
  defp _parse([ opener = %Line.HtmlOpenTag{tag: tag} | rest], result, filename) do
    {status, {html_lines, rest}} = html_match_to_closing(tag, rest, [opener])
    unless status == :ok do
      emit_error filename, opener, :warning, "Failed to find closing <#{tag}>"
    end
    html = (for line <- Enum.reverse(html_lines), do: line.line)
    _parse(rest, [ %Html{tag: tag, html: html} | result ], filename)
  end

  ####################
  # HTML on one line #
  ####################

  defp _parse([ %Line.HtmlOneLine{line: line} | rest], result, filename) do
    _parse(rest, [ %HtmlOther{html: [ line ]} | result ], filename)
  end

  ################
  # HTML Comment #
  ################

  defp _parse([ line = %Line.HtmlComment{complete: true} | rest], result, filename) do
    _parse(rest, [ %HtmlOther{html: [ line.line ]} | result ], filename)
  end

  defp _parse(lines = [ %Line.HtmlComment{complete: false} | _], result, filename) do
    {html_lines, rest} = Enum.split_while(lines, fn (line) ->
      !(line.line =~ ~r/-->/)
    end)
    {html_lines, rest} = if length(rest) == 0 do
      {html_lines, rest}
    else
      {html_lines ++ [ hd(rest) ], tl(rest)}
    end
    html = (for line <- html_lines, do: line.line)
    _parse(rest, [ %HtmlOther{html: html} | result ], filename)
  end

  #################
  # ID definition #
  #################

  # the title may be on the line following the iddef
  defp _parse( [ defn = %Line.IdDef{title: title}, maybe_title | rest ], result, filename)
  when title == nil
  do
    title = case maybe_title do
      %Line.Text{content: content}   ->  Line.matches_id_title(content)
      %Line.Indent{content: content} ->  Line.matches_id_title(content)
      _                              ->  nil
    end

    if title do
      _parse(rest, [ %IdDef{id: defn.id, url: defn.url, title: title} | result], filename)
    else
      _parse([maybe_title | rest], [ %IdDef{id: defn.id, url: defn.url} | result], filename)
    end
  end

  # or not
  defp _parse( [ defn = %Line.IdDef{} | rest ], result, filename) do
    _parse(rest, [ %IdDef{id: defn.id, url: defn.url, title: defn.title} | result], filename)
  end

  #######################
  # Footnote Definition #
  #######################

  defp _parse( [ defn = %Line.FnDef{id: _id} | rest ], result , filename) do
    {para_lines, rest} = Enum.split_while(rest, &text?/1)
    first_line = %Line.Text{line: defn.content}
    para = _parse([ first_line | para_lines ], [], filename)
    {indent_lines, rest} = Enum.split_while(rest, &indent_or_blank?/1)
    {blocks, _ } = remove_trailing_blank_lines(indent_lines)
                |> Enum.map(&(properly_indent(&1, 1)))
                |> Parser.parse(%Earmark.Options{}, true)
    blocks = Enum.concat(para, blocks)
    _parse( rest, [ %FnDef{id: defn.id, blocks: blocks } | result ] , filename)
  end

  ####################
  # IAL (attributes) #
  ####################

  defp _parse( [ %Line.Ial{attrs: attrs} | rest ], result, filename) do
    _parse(rest, [ %Ial{attrs: attrs} | result ], filename)
  end

  ###############
  # Blank Lines #
  ###############
  # We've reached the point where empty lines are no longer significant

  defp _parse( [ %Line.Blank{} | rest ], result, filename) do
    _parse(rest, result, filename)
  end

  ##############################################################
  # Anything else... we warn, then treat it as if it were text #
  ##############################################################

  defp _parse( [ anything | rest ], result, filename) do
    emit_error filename, anything, :warning, "Unexpected line #{anything.line}"
    _parse( [ %Line.Text{content: anything.line} | rest], result, filename)
  end

  #######################################################
  # Assign attributes that follow a block to that block #
  #######################################################

  @spec assign_attributes_to_blocks( ts, ts ) :: ts
  def assign_attributes_to_blocks([], result), do: Enum.reverse(result)

  def assign_attributes_to_blocks([ %Ial{attrs: attrs}, block | rest], result) do
    assign_attributes_to_blocks(rest, [ %{block | attrs: attrs} | result ])
  end

  def assign_attributes_to_blocks([ block | rest], result) do
    assign_attributes_to_blocks(rest, [ block | result ])
  end

  ############################################################
  # Consolidate multiline inline code blocks into an element #
  ############################################################
  @not_pending {nil, 0}
  # ([#{},...]) -> {[#{}],[#{}],{'nil' | binary(),number()}}
  # @spec consolidate_para( ts ) :: { ts, ts, {nil | String.t, number} }
  defp consolidate_para( lines ), do: _consolidate_para( lines, [], @not_pending )

  @spec _consolidate_para( ts, ts, inline_code_continuation ) :: { ts, ts, inline_code_continuation }
  defp _consolidate_para( [], result, pending ) do
    {result, [], pending}
  end

  defp _consolidate_para( [line | rest] = lines, result, pending ) do
    case inline_or_text?( line, pending ) do
      %{pending: still_pending, continue: true} -> _consolidate_para( rest, [line | result], still_pending )
      _                                         -> {result, lines, @not_pending}
    end

  end

  ##################################################
  # Consolidate one or more list items into a list #
  ##################################################

  @spec consolidate_list_items( ts, ts ) :: ts
  defp consolidate_list_items([], result), do: result  # no need to reverse

  # We have a list, and the next element is an item of the same type
  defp consolidate_list_items(
    [list = %List{type: type, blocks: items},
     item = %ListItem{type: type} | rest], result)
  do
    items = [ item | items ]   # original list is reversed
    consolidate_list_items([ %{ list | blocks: items } | rest ], result)
  end

  # We have an item, but no open list
  defp consolidate_list_items([ item = %ListItem{type: type} | rest], result) do
    consolidate_list_items([ %List{ type: type, blocks: [ item ] } | rest ], result)
  end

  # Nothing to see here, move on
  defp consolidate_list_items([ head | rest ], result) do
    consolidate_list_items(rest, [ head | result ])
  end

  ##################################################
  # Read in a table (consecutive TableLines with
  # the same number of columns)

  @spec read_table( ts, number, %Table{} ) :: { %Table{}, ts }
  defp read_table([ %Line.TableLine{columns: cols} | rest ],
                    col_count,
                    table = %Table{})
  when length(cols) == col_count
  do
    read_table(rest, col_count, update_in(table.rows, &[ cols | &1 ]))
  end

  defp read_table( rest, col_count, %Table{rows: rows}) do
    rows  = Enum.reverse(rows)
    table = Table.new_for_columns(col_count)
    table = case look_for_alignments(rows) do
      nil    -> %Table{table | rows: rows }
      aligns -> %Table{table | alignments: aligns,
                               header:     hd(rows),
                               rows:       tl(tl(rows)) }
    end
    { table , rest }
  end


  @spec look_for_alignments( [String.t] ) :: atom
  defp look_for_alignments([ _first, second | _rest ]) do
    if Enum.all?(second, fn row -> row =~ ~r{^:?-+:?$} end) do
      second
      |> Enum.map(fn row -> Regex.replace(~r/-+/, row, "-") end)
      |> Enum.map(fn row -> case row do
           ":-:" -> :center
           ":-"  -> :left
           "-"   -> :left
           "-:"  -> :right
         end
      end)
    else
      nil
    end
  end


  #####################################################
  # Traverse the block list and build a list of links #
  #####################################################

  defp links_from_blocks(blocks) do
    visit(blocks, Map.new, &link_extractor/2)
  end

  @spec link_extractor(t, %{}) :: %{}
  defp link_extractor(item = %IdDef{id: id}, result) do
    Map.put(result, String.downcase(id), item)
  end

  defp link_extractor(_, result), do: result


  ##################################
  # Visitor pattern for each block #
  ##################################

  @spec visit(ts, %{}, (t, %{} -> %{})) :: %{}
  defp visit([], result, _func), do: result

  defp visit([ item = %BlockQuote{blocks: blocks} | rest], result, func) do
    result = func.(item, result)
    result = visit(blocks, result, func)
    visit(rest, result, func)
  end

  defp visit([ item = %List{blocks: blocks} | rest], result, func) do
    result = func.(item, result)
    result = visit(blocks, result, func)
    visit(rest, result, func)
  end

  defp visit([ item = %ListItem{blocks: blocks} | rest], result, func) do
    result = func.(item, result)
    result = visit(blocks, result, func)
    visit(rest, result, func)
  end

  defp visit([ item | rest], result, func) do
    result = func.(item, result)
    visit(rest, result, func)
  end

  ###################################################################
  # Consume HTML, taking care of nesting. Assumes one tag per line. #
  ###################################################################

  # run out of input
  defp html_match_to_closing(_tag, [], result) do
    {:error, { result, [] }}
  end

  # find closing tag
  defp html_match_to_closing(tag,
                             [closer = %Line.HtmlCloseTag{tag: tag} | rest],
                             result)
  do
    {:ok, { [closer | result], rest }}
  end

  # a nested open tag
  defp html_match_to_closing(tag,
                             [opener = %Line.HtmlOpenTag{tag: new_tag} | rest],
                             result)
  do
    case html_match_to_closing(new_tag, rest, [opener]) do
      {:ok, { html_lines, rest }} ->  html_match_to_closing(tag, rest, html_lines ++ result)
      error                       ->  error
    end
  end

  # anything else
  defp html_match_to_closing(tag, [ line | rest ], result) do
    html_match_to_closing(tag, rest, [ line | result ])
  end


  ###########
  # Helpers #
  ###########


  # (_,{'nil' | binary(),number()}) -> #{}jj
  @spec inline_or_text?( Line.t, inline_code_continuation ) :: %{pending: String.t, continue: boolean}
  defp inline_or_text?(line, pending)
  defp inline_or_text?(line = %Line.Text{}, @not_pending) do
    pending = opens_inline_code(line)
    %{pending: pending, continue: true}
  end
  defp inline_or_text?(line = %Line.TableLine{}, @not_pending) do
    pending = opens_inline_code(line)
    %{pending: pending, continue: true}
  end
  defp inline_or_text?( _line, @not_pending), do: %{pending: @not_pending, continue: false}
  defp inline_or_text?( line, pending ) do
    pending = still_inline_code(line, pending)
    %{pending: pending, continue: true}
  end


  defp peek([], _, _), do: false
  defp peek([head | _], struct, type) do
    head.__struct__ == struct && head.type == type
  end

  # In case we are inside a code block we return the verbatim text
  defp properly_indent(%{inside_code: true, line: line}, _level) do
    line
  end
  # Add additional spaces for any indentation past level 1
  defp properly_indent(%Line.Indent{level: level, content: content}, target_level)
  when level == target_level do
    content
  end

  defp properly_indent(%Line.Indent{level: level, content: content}, target_level)
  when level > target_level do
    String.duplicate("    ", level-target_level) <> content
  end

  defp properly_indent(line, _) do
    line.content
  end

  defp remove_trailing_blank_lines(lines) do
    lines
    |> Enum.reverse
    |> Enum.drop_while(&blank?/1)
    |> Enum.reverse
  end
end
