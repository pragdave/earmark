defmodule Earmark.Block do

  import Earmark.Helpers, only: [pending_inline_code: 1, still_pending_inline_code: 2]

  @moduledoc """
  Given a list of parsed blocks, convert them into blocks.
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

  @doc false
  # Given a list of `Line.xxx` structs, group them into related blocks.
  # Then extract any id definitions, and build a hashdict from them. Not
  # for external consumption.
  def parse(lines) do
    blocks = lines_to_blocks(lines)
    links  = links_from_blocks(blocks)
    { blocks, links }
  end

  @doc false
  # Public to allow easier testing
  def lines_to_blocks(lines) do
    lines
    |> parse([])
    |> assign_attributes_to_blocks([])
    |> consolidate_list_items([])
  end



  defp parse([], result), do: result     # consolidate also reverses, so no need

  ###################
  # setext headings #
  ###################

  defp parse([  %Line.Blank{},
                %Line.Text{content: heading},
                %Line.SetextUnderlineHeading{level: level}

             |
                rest
             ], result) do

    parse(rest, [ %Heading{content: heading, level: level} | result ])
  end

  defp parse([  %Line.Blank{},
                %Line.Text{content: heading},
                %Line.Ruler{type: "-"}

             |
                rest
             ], result) do

    parse(rest, [ %Heading{content: heading, level: 2} | result ])
  end


  #################
  # Other heading #
  #################

  defp parse([ %Line.Heading{content: content, level: level} | rest ], result) do
    parse(rest, [ %Heading{content: content, level: level} | result ])
  end

  #########
  # Ruler #
  #########

  defp parse([ %Line.Ruler{type: type} | rest], result) do
    parse(rest, [ %Ruler{type: type} | result ])
  end

  ###############
  # Block Quote #
  ###############

  defp parse( lines = [ %Line.BlockQuote{} | _ ], result) do
    {quote_lines, rest} = Enum.split_while(lines, &is_blockquote_or_text/1)
    lines = for line <- quote_lines, do: line.content
    {blocks, _} = Parser.parse(lines, true)
    parse(rest, [ %BlockQuote{blocks: blocks} | result ])
  end

  #########
  # Table #
  #########

  defp parse( lines = [ %Line.TableLine{columns: cols1},
                        %Line.TableLine{columns: cols2}
                      | _rest
                      ], result)
  when length(cols1) == length(cols2)
  do
    columns = length(cols1)
    { table, rest } = read_table(lines, columns, Table.new_for_columns(columns))
    parse(rest, [ table | result ])
  end

  #############
  # Paragraph #
  #############

  defp parse( lines = [ %Line.TableLine{} | _ ], result) do
    {para_lines, rest} = Enum.split_while(lines, &is_text/1)
    line_text = (for line <- para_lines, do: line.line)
    parse(rest, [ %Para{lines: line_text} | result ])
  end

  defp parse( lines = [ %Line.Text{} | _ ], result)
  do
    {reversed_para_lines, rest} = consolidate_para( lines )
    line_text = (for line <- (reversed_para_lines |> Enum.reverse), do: line.line)
    parse(rest, [ %Para{lines: line_text} | result ])
  end

  #########
  # Lists #
  #########
  # We handle lists in two passes. In the first, we build list items,
  # in the second we combine adjacent items into lists. This is pass one

  defp parse( [first = %Line.ListItem{type: type} | rest ], result) do
    {spaced, list_lines, rest} = read_list_lines(rest, [], pending_inline_code(first.line))

    spaced = (spaced || blank_line_in?(list_lines)) && peek(rest, Line.ListItem, type)
    lines = for line <- [first | list_lines], do: properly_indent(line, 1)
    {blocks, _} = Parser.parse(lines, true)

    parse(rest, [ %ListItem{type: type, blocks: blocks, spaced: spaced} | result ])
  end

  #################
  # Indented code #
  #################

  defp parse( list = [%Line.Indent{} | _], result) do
    {code_lines, rest} = Enum.split_while(list, &is_indent_or_blank/1)
    code_lines = remove_trailing_blank_lines(code_lines)
    code = (for line <- code_lines, do: properly_indent(line, 1))
    parse(rest, [ %Code{lines: code} | result ])
  end

  ###############
  # Fenced code #
  ###############

  defp parse([%Line.Fence{delimiter: delimiter, language: language} | rest], result) do
    {code_lines, rest} = Enum.split_while(rest, fn (line) ->
      !match?(%Line.Fence{delimiter: ^delimiter, language: _}, line)
    end)
    unless length(rest) == 0, do: rest = tl(rest)
    code = (for line <- code_lines, do: line.line)
    parse(rest, [ %Code{lines: code, language: language} | result ])
  end

  ##############
  # HTML block #
  ##############
  defp parse([ opener = %Line.HtmlOpenTag{tag: tag} | rest], result) do
    {html_lines, rest} = html_match_to_closing(tag, rest, [opener])
    html = (for line <- Enum.reverse(html_lines), do: line.line)
    parse(rest, [ %Html{tag: tag, html: html} | result ])
  end

  ####################
  # HTML on one line #
  ####################

  defp parse([ %Line.HtmlOneLine{line: line} | rest], result) do
    parse(rest, [ %HtmlOther{html: [ line ]} | result ])
  end

  ################
  # HTML Comment #
  ################

  defp parse([ line = %Line.HtmlComment{complete: true} | rest], result) do
    parse(rest, [ %HtmlOther{html: [ line.line ]} | result ])
  end

  defp parse(lines = [ %Line.HtmlComment{complete: false} | _], result) do
    {html_lines, rest} = Enum.split_while(lines, fn (line) ->
      !(line.line =~ ~r/-->/)
    end)
    unless length(rest) == 0 do
      html_lines = html_lines ++ [ hd(rest) ]
      rest = tl(rest)
    end
    html = (for line <- html_lines, do: line.line)
    parse(rest, [ %HtmlOther{html: html} | result ])
  end

  #################
  # ID definition #
  #################

  # the title may be on the line following the iddef
  defp parse( [ defn = %Line.IdDef{title: title}, maybe_title | rest ], result)
  when title == nil
  do
    title = case maybe_title do
      %Line.Text{content: content}   ->  Line.matches_id_title(content)
      %Line.Indent{content: content} ->  Line.matches_id_title(content)
      _                              ->  nil
    end

    if title do
      parse(rest, [ %IdDef{id: defn.id, url: defn.url, title: title} | result])
    else
      parse([maybe_title | rest], [ %IdDef{id: defn.id, url: defn.url} | result])
    end
  end

  # or not
  defp parse( [ defn = %Line.IdDef{} | rest ], result) do
    parse(rest, [ %IdDef{id: defn.id, url: defn.url, title: defn.title} | result])
  end

  #######################
  # Footnote Definition #
  #######################

  defp parse( [ defn = %Line.FnDef{id: _id} | rest ], result ) do
    {para_lines, rest} = Enum.split_while(rest, &is_text/1)
    first_line = %Line.Text{line: defn.content}
    para = parse([ first_line | para_lines ], [])
    {indent_lines, rest} = Enum.split_while(rest, &is_indent_or_blank/1)
    {blocks, _ } = remove_trailing_blank_lines(indent_lines)
                |> Enum.map(&(properly_indent(&1, 1)))
                |> Parser.parse(true)
    blocks = Enum.concat(para, blocks)
    parse( rest, [ %FnDef{id: defn.id, blocks: blocks } | result ] )
  end

  ####################
  # IAL (attributes) #
  ####################

  defp parse( [ %Line.Ial{attrs: attrs} | rest ], result) do
    parse(rest, [ %Ial{attrs: attrs} | result ])
  end

  ###############
  # Blank Lines #
  ###############
  # We've reached the point where empty lines are no longer significant

  defp parse( [ %Line.Blank{} | rest ], result) do
    parse(rest, result)
  end

  ##############################################################
  # Anything else... we warn, then treat it as if it were text #
  ##############################################################

  defp parse( [ anything | rest ], result) do
    IO.puts(:stderr, "Unexpected line #{anything.line}")
    parse( [ %Line.Text{content: anything.line} | rest], result)
  end

  #######################################################
  # Assign attributes that follow a block to that block #
  #######################################################

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
  defp consolidate_para( lines ), do: consolidate_para( lines, [], false )
  defp consolidate_para( [], result, false ), do: {result, []}
  defp consolidate_para( [], result, pending ) do
    IO.puts( :stderr, "Closing unclosed backquotes #{pending} at end of input" )
    {result, []}
  end

  defp consolidate_para( [line | rest] = lines, result, pending ) do
    case is_inline_or_text( line, pending ) do
      %{pending: still_pending, continue: true} -> consolidate_para( rest, [line | result], still_pending )
      _                                         -> {result, lines}
    end

  end

  ##################################################
  # Consolidate one or more list items into a list #
  ##################################################

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

  ##################################################
  # Called to slurp in the lines for a list item.
  # basically, we allow indents and blank lines, and
  # we allow text lines only after an indent (and initially)
  # We also slurp in lines that are inside a multiline inline
  # code block as indicated by the third param

  # text immediately after the start
  defp read_list_lines([ line = %Line.Text{line: text} | rest ], [], false) do
    read_list_lines(rest, [ line ], pending_inline_code(text))
  end
  # table line immediately after the start
  defp read_list_lines([ line = %Line.TableLine{line: text} | rest ], [], false) do
    read_list_lines(rest, [ line ], pending_inline_code(text))
  end

  # text immediately after another text line
  defp read_list_lines([ line = %Line.Text{line: text} | rest ], result =[ %Line.Text{} | _], false) do
    read_list_lines(rest, [ line | result ], pending_inline_code(text))
  end
  # table line immediately after another text line
  defp read_list_lines([ line = %Line.TableLine{line: text} | rest ], result =[ %Line.Text{} | _], false) do
    read_list_lines(rest, [ line | result ], pending_inline_code(text))
  end

  # text immediately after a table line
  defp read_list_lines([ line = %Line.Text{line: text} | rest ], result =[ %Line.TableLine{} | _], false) do
    read_list_lines(rest, [ line | result ], pending_inline_code(text))
  end
  # table line immediately after another table line
  defp read_list_lines([ line = %Line.TableLine{line: text} | rest ], result =[ %Line.TableLine{} | _], false) do
    read_list_lines(rest, [ line | result ], pending_inline_code(text))
  end

  # text immediately after an indent
  defp read_list_lines([ line = %Line.Text{line: text} | rest ], result =[ %Line.Indent{} | _], false) do
    read_list_lines(rest, [ line | result ], pending_inline_code(text))
  end
  # table line immediately after an indent
  defp read_list_lines([ line = %Line.TableLine{line: text} | rest ], result =[ %Line.Indent{} | _], false) do
    read_list_lines(rest, [ line | result ], pending_inline_code(text))
  end

  # Always allow blank lines and indents, and text or table lines with at least
  # two spaces
  defp read_list_lines([ line = %Line.Blank{} | rest ], result, false) do
    read_list_lines(rest, [ line | result ], false)
  end

  defp read_list_lines([ line = %Line.Indent{line: text} | rest ], result, false) do
    read_list_lines(rest, [ line | result ], pending_inline_code(text))
  end

  defp read_list_lines([ line = %Line.Text{line: ( text = <<"  ", _ :: binary>> )} | rest ],
                         result, false)
  do
    read_list_lines(rest, [ line | result ], pending_inline_code(text))
  end

  defp read_list_lines([ line = %Line.TableLine{content: ( text = <<"  ", _ :: binary>> )} | rest ],
                         result, false)
  do
    read_list_lines(rest, [ line | result ], pending_inline_code(text))
  end

  # no match, must be done
  defp read_list_lines(lines, result, false) do
    { trailing_blanks, rest } = Enum.split_while(result, &is_blank/1)
    spaced = length(trailing_blanks) > 0
    { spaced, Enum.reverse(rest), lines }
  end

  # Only now we match for list lines inside an open multiline inline code block
  defp read_list_lines([line|rest], result, opening_backquotes) do
    read_list_lines(rest, [%{line|inside_code: true} | result], still_pending_inline_code(line.line, opening_backquotes))
  end
  # Running into EOI insise an open multiline inline code block
  defp read_list_lines([], result, opening_backquotes) do
    IO.puts( :stderr, "Closing unclosed backquotes #{opening_backquotes} at end of input" )
    read_list_lines( [], result, false )
  end

  #####################################################
  # Traverse the block list and build a list of links #
  #####################################################

  defp links_from_blocks(blocks) do
    visit(blocks, HashDict.new, &link_extractor/2)
  end

  defp link_extractor(item = %IdDef{id: id}, result) do
    Dict.put(result, String.downcase(id), item)
  end

  defp link_extractor(_, result), do: result


  ##################################
  # Visitor pattern for each block #
  ##################################

  def visit([], result, _func), do: result

  def visit([ item = %BlockQuote{blocks: blocks} | rest], result, func) do
    result = func.(item, result)
    result = visit(blocks, result, func)
    visit(rest, result, func)
  end

  def visit([ item = %List{blocks: blocks} | rest], result, func) do
    result = func.(item, result)
    result = visit(blocks, result, func)
    visit(rest, result, func)
  end

  def visit([ item = %ListItem{blocks: blocks} | rest], result, func) do
    result = func.(item, result)
    result = visit(blocks, result, func)
    visit(rest, result, func)
  end

  def visit([ item | rest], result, func) do
    result = func.(item, result)
    visit(rest, result, func)
  end

  ###################################################################
  # Consume HTML, taking care of nesting. Assumes one tag per line. #
  ###################################################################

  # run out of input
  defp html_match_to_closing(tag, [], result) do
    IO.puts(:stderr, "Failed to find closing <#{tag}>")
    { result, [] }
  end

  # find closing tag
  defp html_match_to_closing(tag,
                             [closer = %Line.HtmlCloseTag{tag: tag} | rest],
                             result)
  do
    { [closer | result], rest }
  end

  # a nested open tag
  defp html_match_to_closing(tag,
                             [opener = %Line.HtmlOpenTag{tag: new_tag} | rest],
                             result)
  do
    { html_lines, rest } = html_match_to_closing(new_tag, rest, [opener])
    html_match_to_closing(tag, rest, html_lines ++ result)
  end

  # anything else
  defp html_match_to_closing(tag, [ line | rest ], result) do
    html_match_to_closing(tag, rest, [ line | result ])
  end


  ###########
  # Helpers #
  ###########

  defp is_blank(%Line.Blank{}),   do: true
  defp is_blank(_),               do: false

  # Gruber's tests have
  #
  #   para text...
  #   * and more para text
  #
  # So list markers inside paragraphs are ignored. But he also has
  #
  #   *   line
  #       * line
  #
  # And expects it to be a nested list. These seem to be in conflict
  #
  # I think the second is a better interpretation, so I commented
  # out the 2nd match below.

  defp is_text(%Line.Text{}),      do: true
  defp is_text(%Line.TableLine{}), do: true
#  defp is_text(%Line.ListItem{}), do: true
  defp is_text(_),                 do: false

  defp is_blockquote_or_text(%Line.BlockQuote{}), do: true
  defp is_blockquote_or_text(struct),             do: is_text(struct)

  defp is_indent_or_blank(%Line.Indent{}), do: true
  defp is_indent_or_blank(line),           do: is_blank(line)

  defp is_inline_or_text(line, pending)
  defp is_inline_or_text(line = %Line.Text{}, false) do
    %{pending: pending_inline_code(line.line), continue: true}
  end
  defp is_inline_or_text(line = %Line.TableLine{}, false) do
    %{pending: pending_inline_code(line.line), continue: true}
  end
  defp is_inline_or_text( _line, false), do: %{pending: false, continue: false}
  defp is_inline_or_text( line, pending ) do
    %{pending: still_pending_inline_code( line.line, pending ), continue: true}
  end


  defp peek([], _, _), do: false
  defp peek([head | _], struct, type) do
    head.__struct__ == struct && head.type == type
  end

  defp blank_line_in?([]),                    do: false
  defp blank_line_in?([ %Line.Blank{} | _ ]), do: true
  defp blank_line_in?([ _ | rest ]),          do: blank_line_in?(rest)


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
    |> Enum.drop_while(&is_blank/1)
    |> Enum.reverse
  end
end
