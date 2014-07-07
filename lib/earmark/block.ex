defmodule Earmark.Block do

  alias Earmark.Line
  alias Earmark.Parser


  defmodule Heading,    do: defstruct content: nil, level: nil
  defmodule Ruler,      do: defstruct type: nil
  defmodule BlockQuote, do: defstruct blocks: []
  defmodule List,       do: defstruct type: :ul, blocks:  []
  defmodule ListItem,   do: defstruct type: :ul, spaced: true, blocks: []
  defmodule Para,       do: defstruct lines:  []
  defmodule Code,       do: defstruct lines:  [], language: nil
  defmodule Html,       do: defstruct html:   [], tag: nil
  defmodule IdDef,      do: defstruct id: nil, url: nil, title: nil


  @doc """
  Given a list of `Line.xxx` structs, group them into related blocks. 
  Then extract any id definitions, and build a hashdict from them.
  """
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
    |> consolidate_list_items([])
  end



  defp parse([], result), do: result     # consolidate also reverses, so no need

  ###################
  # setext headings #
  ###################

  defp parse([ %Line.Blank{}, 
              %Line.Text{content: heading},
              %Line.SetextUnderlineHeading{level: level},
              %Line.Blank{}
            | 
              rest
            ], result) do

    parse(rest, [ %Heading{content: heading, level: level} | result ])
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
    blocks = Parser.parse(for line <- quote_lines, do: line.content)
    parse(rest, [ %BlockQuote{blocks: blocks} | result ])
  end

  #############
  # Paragraph #
  #############

  defp parse( lines = [ %Line.Text{} | _ ], result) do
    {para_lines, rest} = Enum.split_while(lines, &is_text/1)
    line_text = (for line <- para_lines, do: line.content)
    parse(rest, [ %Para{lines: line_text} | result ])
  end

  #########
  # Lists #
  #########
  # We handle lists in two passes. In the first, we build list items,
  # in the second we combine adjacent items into lists. This is pass one

  defp parse( [first = %Line.ListItem{type: type} | rest ], result) do
    {list_lines, rest} = read_list_lines(rest, [])
    spaced = blank_line_in?(list_lines) || !peek(rest, Line.ListItem, type)
    blocks = Parser.parse(for line <- [first | list_lines], do: properly_indent(line, 1))
    parse(rest, [ %ListItem{type: type, blocks: blocks, spaced: spaced} | result ])
  end

  #################
  # Indented code #
  #################

  defp parse( list = [%Line.Indent{} | _], result) do
    {code_lines, rest} = Enum.split_while(list, &is_indent_or_blank/1)
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
  defp parse(lines = [%Line.HtmlOpenTag{tag: tag} | _], result) do
    {html_lines, rest} = Enum.split_while(lines, fn (line) ->
      !match?(%Line.HtmlCloseTag{tag: ^tag}, line)
    end)
    unless length(rest) == 0, do: rest = tl(rest)
    html = (for line <- html_lines, do: line.line)
    parse(rest, [ %Html{tag: tag, html: html} | result ])
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

  ###############
  # Blank Lines #
  ###############
  # We've reached the point where empty lines are no longer significant 

  defp parse( [ %Line.Blank{} | rest ], result) do
    parse(rest, result)
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
  # Called to slurp in the lines for a list item. 
  # basically, we allow indents and blank lines, and
  # we allow text lines only after an indent (and initially)

  # immediately after the start
  defp read_list_lines([ line = %Line.Text{} | rest ], []) do
    read_list_lines(rest, [ line ])
  end

  # Immediately after another text line
  defp read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Text{} | _]) do
    read_list_lines(rest, [ line | result ])
  end

  # Immediately after an indent
  defp read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Indent{} | _]) do
    read_list_lines(rest, [ line | result ])
  end

  # Always allow blank lines and indents
  defp read_list_lines([ line = %Line.Indent{} | rest ], result) do
    read_list_lines(rest, [ line | result ])
  end

  defp read_list_lines([ line = %Line.Blank{} | rest ], result) do
    read_list_lines(rest, [ line | result ])
  end

  # no match, must be done
  defp read_list_lines(lines, result) do
    { Enum.reverse(result), lines }
  end

  #####################################################
  # Traverse the block list and build a list of links #
  #####################################################

  defp links_from_blocks(blocks) do
    visit(blocks, HashDict.new, &link_extractor/2)
  end

  defp link_extractor(item = %IdDef{id: id}, result), do: Dict.put(result, id, item)
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

  ###########
  # Helpers #
  ###########

  defp is_text(%Line.Text{}), do: true
  defp is_text(_),            do: false

  defp is_blockquote_or_text(%Line.BlockQuote{}), do: true
  defp is_blockquote_or_text(struct),             do: is_text(struct)

  defp is_indent_or_blank(%Line.Indent{}), do: true
  defp is_indent_or_blank(%Line.Blank{}),  do: true
  defp is_indent_or_blank(_),              do: false

  defp peek([], _, _), do: false
  defp peek([head | _], struct, type) do
    head.__struct__ == struct && head.type == type
  end

  defp blank_line_in?([]),                    do: false
  defp blank_line_in?([ %Line.Blank{} | _ ]), do: true
  defp blank_line_in?([ _ | rest ]),          do: blank_line_in?(rest)
  

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

end