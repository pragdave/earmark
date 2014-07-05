defmodule Earmark.Block do

  alias Earmark.Line
  alias Earmark.Parser


  defmodule Heading,    do: defstruct content: nil, level: nil
  defmodule Ruler,      do: defstruct type: nil
  defmodule BlockQuote, do: defstruct blocks: []
  defmodule List,       do: defstruct items:  []
  defmodule UlItem,     do: defstruct spaced: true, blocks: []
  defmodule Para,       do: defstruct lines:  []
  defmodule Code,       do: defstruct lines:  [], language: nil
  defmodule Html,       do: defstruct html:   [], tag: nil

  # defmodule IdDef,        do: defstruct id: nil, url: nil, title: nil
  # defmodule OlItem,       do: defstruct bullet: "* or -", content: "text"


  def lines_to_blocks(lines) do
    lines
    |> parse([])
    |> consolidate_list_items([])
  end



  def parse([], result), do: result     # consolidate also reverses, so no need

  ###################
  # setext headings #
  ###################

  def parse([ %Line.Blank{}, 
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

  def parse([ %Line.Heading{content: content, level: level} | rest ], result) do
    parse(rest, [ %Heading{content: content, level: level} | result ])
  end

  #########
  # Ruler #
  #########

  def parse([ %Line.Ruler{type: type} | rest], result) do
    parse(rest, [ %Ruler{type: type} | result ])
  end

  ###############
  # Block Quote #
  ###############

  def parse( lines = [ %Line.BlockQuote{} | _ ], result) do
    {quote_lines, rest} = Enum.split_while(lines, &is_blockquote_or_text/1)
    blocks = Parser.parse(for line <- quote_lines, do: line.content)
    parse(rest, [ %BlockQuote{blocks: blocks} | result ])
  end

  #############
  # Paragraph #
  #############

  def parse( lines = [ %Line.Text{} | _ ], result) do
    {para_lines, rest} = Enum.split_while(lines, &is_text/1)
    line_text = (for line <- para_lines, do: line.content)
    parse(rest, [ %Para{lines: line_text} | result ])
  end

  #########
  # Lists #
  #########
  # We handle lists in two passes. In the first, we build list items,
  # in the second we combine adjacent items into lists. This is pass one

  def parse( [first = %Line.UlItem{} | rest ], result) do
    {list_lines, rest} = read_list_lines(rest, [])
    spaced = blank_line_in?(list_lines) || !peek(rest, Line.UlItem)
#    IO.inspect(list_lines)
#    IO.inspect(for line <- [ first | list_lines], do: properly_indent(line,1))
    blocks = Parser.parse(for line <- [first | list_lines], do: properly_indent(line, 1))
    parse(rest, [ %UlItem{blocks: blocks, spaced: spaced} | result ])
  end

  #################
  # Indented code #
  #################

  def parse( list = [%Line.Indent{} | _], result) do
    {code_lines, rest} = Enum.split_while(list, &is_indent_or_blank/1)
    code = (for line <- code_lines, do: properly_indent(line, 1))
    parse(rest, [ %Code{lines: code} | result ])
  end

  ###############
  # Fenced code #
  ###############

  def parse([%Line.Fence{delimiter: delimiter, language: language} | rest], result) do
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
  def parse(lines = [%Line.HtmlOpenTag{tag: tag} | _], result) do
    {html_lines, rest} = Enum.split_while(lines, fn (line) ->
      !match?(%Line.HtmlCloseTag{tag: ^tag}, line)
    end)
    unless length(rest) == 0, do: rest = tl(rest)
    html = (for line <- html_lines, do: line.line)
    parse(rest, [ %Html{tag: tag, html: html} | result ])
  end

  ###############
  # Blank Lines #
  ###############
  # We've reached the point where empty lines are no longer significant 

  def parse( [ %Line.Blank{} | rest ], result) do
    parse(rest, result)
  end


  ##################################################
  # Consolidate one or more list items into a list #
  ##################################################

  def consolidate_list_items([], result), do: result  # no need to reverse

  # We have a list, and the next element is an item
  def consolidate_list_items(
    [list = %List{items: items}, item = %UlItem{} | rest], result) do
    items = [ item | items ]   # original list is reverses
    consolidate_list_items([ %{ list | items: items } | rest ], result)
  end

  # We have an item, but no open list
  def consolidate_list_items([ item = %UlItem{} | rest], result) do
    consolidate_list_items([ %List{ items: [ item ] } | rest ], result)
  end

  # Nothing to see here, move on
  def consolidate_list_items([ head | rest ], result) do
    consolidate_list_items(rest, [ head | result ])
  end

  ##################################################
  # Called to slurp in the lines for a list item. 
  # basically, we allow indents and blank lines, and
  # we allow text lines only after an indent (and initially)

  # immediately after the start
  def read_list_lines([ line = %Line.Text{} | rest ], []) do
    read_list_lines(rest, [ line ])
  end

  # Immediately after another text line
  def read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Text{} | _]) do
    read_list_lines(rest, [ line | result ])
  end

  # Immediately after an indent
  def read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Indent{} | _]) do
    read_list_lines(rest, [ line | result ])
  end

  # Always allow blank lines and indents
  def read_list_lines([ line = %Line.Indent{} | rest ], result) do
    read_list_lines(rest, [ line | result ])
  end

  def read_list_lines([ line = %Line.Blank{} | rest ], result) do
    read_list_lines(rest, [ line | result ])
  end

  # no match, must be done
  def read_list_lines(lines, result) do
    { Enum.reverse(result), lines }
  end

  ###########
  # Helpers #
  ###########

  def is_text(%Line.Text{}), do: true
  def is_text(_),            do: false

  def is_blockquote_or_text(%Line.BlockQuote{}), do: true
  def is_blockquote_or_text(struct),             do: is_text(struct)

  def is_indent_or_blank(%Line.Indent{}), do: true
  def is_indent_or_blank(%Line.Blank{}),  do: true
  def is_indent_or_blank(_),              do: false

  def peek([], _), do: false
  def peek([head | _], struct) do
    head.__struct__ == struct
  end

  def blank_line_in?([]),                    do: false
  def blank_line_in?([ %Line.Blank{} | _ ]), do: true
  def blank_line_in?([ _ | rest ]),          do: blank_line_in?(rest)
  

  # Add additional spaces for any indentation past level 1

  def properly_indent(%Line.Indent{level: level, content: content}, target_level) 
  when level == target_level do
    content
  end

  def properly_indent(%Line.Indent{level: level, content: content}, target_level) 
  when level > target_level do
    String.duplicate("    ", level-target_level) <> content
  end

  def properly_indent(line, _) do
    line.content
  end

end