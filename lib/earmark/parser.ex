defmodule Earmark.Parser do
  alias Earmark.Block
  alias Earmark.Line
  alias Earmark.Options

  import Earmark.Helpers.LookaheadHelpers, only: [opens_inline_code: 1, still_inline_code: 2, read_list_lines: 3]
  import Earmark.Helpers.LineHelpers
  import Earmark.Helpers.AttrParser
  import Earmark.Helpers.ReparseHelpers
  import Earmark.Message, only: [add_message: 2, add_messages: 2]

  @doc """
  Given a markdown document (as either a list of lines or
  a string containing newlines), return a parse tree and
  the context necessary to render the tree.

  The options are a `%Earmark.Options{}` structure. See `as_html!`
  for more details.
  """
  def parse_markdown(lines, options \\ %Options{})
  def parse_markdown(lines, options = %Options{}) when is_list(lines) do
    {blocks, links, options1} = parse(lines, options, false)

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
    |> parse_lines(options)
  end

  @doc false
  # Given a list of `Line.xxx` structs, group them into related blocks.
  # Then extract any id definitions, and build a map from them. Not
  # for external consumption.

  def parse_lines(lines, options) do
    {blocks, options} = lines |> remove_trailing_blank_lines() |> lines_to_blocks(options)
    links  = links_from_blocks(blocks)
    {blocks, links, options}
  end

  defp lines_to_blocks(lines, options) do
    with {blocks, options1} <- lines |> _parse([], options) do
      { blocks |> assign_attributes_to_blocks([]) |> consolidate_list_items([]), options1 }
    end
  end


  defp _parse([], result, options), do: {result, options}

  ###################
  # setext headings #
  ###################

  defp _parse([  %Line.Blank{},
                %Line.Text{content: heading, lnb: lnb},
                %Line.SetextUnderlineHeading{level: level}

             |
                rest
             ], result, options) do

    _parse(rest, [ %Block.Heading{content: heading, level: level, lnb: lnb} | result ], options)
  end

  defp _parse([  %Line.Blank{},
                %Line.Text{content: heading, lnb: lnb},
                %Line.Ruler{type: "-"}
             |
                rest
             ], result, options) do

    _parse(rest, [ %Block.Heading{content: heading, level: 2, lnb: lnb} | result ], options)
  end

  #################
  # Other heading #
  #################

  defp _parse([ %Line.Heading{content: content, level: level, lnb: lnb} | rest ], result, options) do
    _parse(rest, [ %Block.Heading{content: content, level: level, lnb: lnb} | result ], options)
  end

  #########
  # Ruler #
  #########

  defp _parse([ %Line.Ruler{type: type, lnb: lnb} | rest], result, options) do
    _parse(rest, [ %Block.Ruler{type: type, lnb: lnb} | result ], options)
  end

  ###############
  # Block Quote #
  ###############

  defp _parse( lines = [ %Line.BlockQuote{lnb: lnb} | _ ], result, options) do
    {quote_lines, rest} = Enum.split_while(lines, &blockquote_or_text?/1)
    lines = for line <- quote_lines, do: line.content
    {blocks, _, options1} = parse(lines, %{options | line: lnb}, true)
    _parse(rest, [ %Block.BlockQuote{blocks: blocks, lnb: lnb} | result ], options1)
  end

  #########
  # Table #
  #########

  defp _parse( lines = [ %Line.TableLine{columns: cols1, lnb: lnb1},
                        %Line.TableLine{columns: cols2}
                      | _rest
                      ], result, options)
  when length(cols1) == length(cols2)
  do
    columns = length(cols1)
    { table, rest } = read_table(lines, columns, Block.Table.new_for_columns(columns))
    table1          = %{table | lnb: lnb1}
    _parse(rest, [ table1 | result ], options)
  end

  #############
  # Paragraph #
  #############

  defp _parse( lines = [ %Line.TableLine{lnb: lnb} | _ ], result, options) do
    {para_lines, rest} = Enum.split_while(lines, &text?/1)
    line_text = (for line <- para_lines, do: line.line)
    _parse(rest, [ %Block.Para{lines: line_text, lnb: lnb + 1} | result ], options)
  end

  defp _parse( lines = [ %Line.Text{lnb: lnb} | _ ], result, options)
  do
    {reversed_para_lines, rest, pending} = consolidate_para(lines)

    options1 =
      case pending do
        {nil, _} -> options
        {pending, lnb1} ->
          add_message(options, {:warning, lnb1, "Closing unclosed backquotes #{pending} at end of input"})
      end

    line_text = (for line <- (reversed_para_lines |> Enum.reverse), do: line.line)
    _parse(rest, [ %Block.Para{lines: line_text, lnb: lnb} | result ], options1)
  end

  #########
  # Lists #
  #########
  # We handle lists in two passes. In the first, we build list items,
  # in the second we combine adjacent items into lists. This is pass one

  defp _parse( [first = %Line.ListItem{type: type, initial_indent: initial_indent, content: content, bullet: bullet, lnb: lnb} | rest ], result, options) do
    {spaced, list_lines, rest, _offset, indent_level} = read_list_lines(rest, opens_inline_code(first), initial_indent)

    spaced = (spaced || blank_line_in?(list_lines)) && peek(rest, Line.ListItem, type)
    lines = for line <- list_lines, do: indent_list_item_body(line, indent_level || 0)
    lines = [content | lines]
    {blocks, _, options1} = parse(lines, %{options | line: lnb}, true)

    _parse([%Line.Blank{lnb: 0} | rest], [ %Block.ListItem{type: type, blocks: blocks, spaced: spaced, bullet: bullet, lnb: lnb} | result ], options1)
  end

  #################
  # Indented code #
  #################

  defp _parse( list = [%Line.Indent{lnb: lnb} | _], result, options) do
    {code_lines, rest} = Enum.split_while(list, &indent_or_blank?/1)
    code_lines = remove_trailing_blank_lines(code_lines)
    code = (for line <- code_lines, do: properly_indent(line, 1))
    _parse(rest, [ %Block.Code{lines: code, lnb: lnb} | result ], options)
  end

  ###############
  # Fenced code #
  ###############

  defp _parse([%Line.Fence{delimiter: delimiter, language: language, lnb: lnb} | rest], result, options) do
    {code_lines, rest} = Enum.split_while(rest, fn (line) ->
      !match?(%Line.Fence{delimiter: ^delimiter, language: _}, line)
    end)
    rest = if length(rest) == 0, do: rest, else: tl(rest)
    code = (for line <- code_lines, do: line.line)
    _parse(rest, [ %Block.Code{lines: code, language: language, lnb: lnb} | result ], options)
  end

  ##############
  # HTML block #
  ##############
  defp _parse([ opener = %Line.HtmlOpenTag{tag: tag, lnb: lnb} | rest], result, options) do
    {html_lines, rest, unclosed} = html_match_to_closing(opener, rest)
    options1 = add_messages(options,
                            unclosed
                            |> Enum.map(fn %{lnb: lnb1, tag: tag} -> {:warning, lnb1, "Failed to find closing <#{tag}>"} end))

    html = (for line <- Enum.reverse(html_lines), do: line.line)
    _parse(rest, [ %Block.Html{tag: tag, html: html, lnb: lnb} | result ], options1)
  end

  ####################
  # HTML on one line #
  ####################

  defp _parse([ %Line.HtmlOneLine{line: line, lnb: lnb} | rest], result, options) do
    _parse(rest, [ %Block.HtmlOther{html: [ line ], lnb: lnb} | result ], options)
  end

  ################
  # HTML Comment #
  ################

  defp _parse([ line = %Line.HtmlComment{complete: true, lnb: lnb} | rest], result, options) do
    _parse(rest, [ %Block.HtmlOther{html: [ line.line ], lnb: lnb} | result ], options)
  end

  defp _parse(lines = [ %Line.HtmlComment{complete: false, lnb: lnb} | _], result, options) do
    {html_lines, rest} = Enum.split_while(lines, fn (line) ->
      !(line.line =~ ~r/-->/)
    end)
    {html_lines, rest} = if length(rest) == 0 do
      {html_lines, rest}
    else
      {html_lines ++ [ hd(rest) ], tl(rest)}
    end
    html = (for line <- html_lines, do: line.line)
    _parse(rest, [ %Block.HtmlOther{html: html, lnb: lnb} | result ], options)
  end

  #################
  # ID definition #
  #################

  # the title may be on the line following the iddef
  defp _parse( [ defn = %Line.IdDef{title: title, lnb: lnb}, maybe_title | rest ], result, options)
  when title == nil
  do
    title = case maybe_title do
      %Line.Text{content: content}   ->  Line.matches_id_title(content)
      _                              ->  nil
    end

    if title do
      _parse(rest, [ %Block.IdDef{id: defn.id, url: defn.url, title: title, lnb: lnb} | result], options)
    else
      _parse([maybe_title | rest], [ %Block.IdDef{id: defn.id, url: defn.url, lnb: lnb} | result], options)
    end
  end

  # or not
  defp _parse( [ defn = %Line.IdDef{lnb: lnb} | rest ], result, options) do
    _parse(rest, [ %Block.IdDef{id: defn.id, url: defn.url, title: defn.title, lnb: lnb} | result], options)
  end

  #######################
  # Footnote Definition #
  #######################

  defp _parse( [ defn = %Line.FnDef{id: _id, lnb: lnb} | rest ], result , options) do
    {para_lines, rest} = Enum.split_while(rest, &text?/1)
    first_line = %Line.Text{line: defn.content, lnb: lnb}
    {para, options1} = _parse([ first_line | para_lines ], [], options)
    {indent_lines, rest} = Enum.split_while(rest, &indent_or_blank?/1)
    {blocks, _, options2} = remove_trailing_blank_lines(indent_lines)
                |> Enum.map(&(properly_indent(&1, 1)))
                |> parse(%{options1 | line: lnb + 1}, true)
    blocks = Enum.concat(para, blocks)
    _parse( rest, [ %Block.FnDef{id: defn.id, blocks: blocks , lnb: lnb} | result ], options2)
  end

  ####################
  # IAL (attributes) #
  ####################

  defp _parse( [ %Line.Ial{attrs: attrs, lnb: lnb, verbatim: verbatim} | rest ], result, options) do
    {options1, attributes} = parse_attrs( options, attrs, lnb )
    _parse(rest, [ %Block.Ial{attrs: attributes, content: attrs, lnb: lnb, verbatim: verbatim} | result ], options1)
  end

  ###############
  # Blank Lines #
  ###############
  # We've reached the point where empty lines are no longer significant

  defp _parse( [ %Line.Blank{} | rest ], result, options) do
    _parse(rest, result, options)
  end

  ##########
  # Plugin #
  ##########

  defp _parse( lines = [%Line.Plugin{prefix: prefix, lnb: lnb}|_], result, options) do
    handler =  Options.plugin_for_prefix(options, prefix)
    {plugin_lines, rest1} = collect_plugin_lines(lines, prefix, [])
    if handler do
      _parse(rest1, [%Block.Plugin{handler: handler, prefix: prefix, lines: plugin_lines, lnb: lnb}|result], options)
    else
      _parse(rest1, result,
        add_message(options, {:warning, lnb,  "lines for undefined plugin prefix #{inspect prefix} ignored (#{lnb}..#{lnb + Enum.count(plugin_lines) - 1})"}))
    end
  end

  ##############################################################
  # Anything else... we warn, then treat it as if it were text #
  ##############################################################

  defp _parse( [ anything = %{lnb: lnb} | rest ], result, options) do
    _parse( [ %Line.Text{content: anything.line, lnb: lnb} | rest], result,
      add_message(options, {:warning, anything.lnb, "Unexpected line #{anything.line}"}))
  end

  #######################################################
  # Assign attributes that follow a block to that block #
  #######################################################

  defp assign_attributes_to_blocks([], result), do: Enum.reverse(result)
  defp assign_attributes_to_blocks([ %Block.Ial{attrs: attrs}, block | rest], result) do
    assign_attributes_to_blocks(rest, [ %{block | attrs: attrs} | result ])
  end
  defp assign_attributes_to_blocks([ block | rest], result) do
    assign_attributes_to_blocks(rest, [ block | result ])
  end

  ############################################################
  # Consolidate multiline inline code blocks into an element #
  ############################################################
  @not_pending {nil, 0}
  # ([#{},...]) -> {[#{}],[#{}],{'nil' | binary(),number()}}
  # @spec consolidate_para( ts ) :: { ts, ts, {nil | String.t, number} }
  defp consolidate_para( lines ), do: _consolidate_para( lines, [], @not_pending )

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

  defp consolidate_list_items([], result) do
    result |> Enum.map(&compute_list_spacing/1)  # no need to reverse
  end
  # We have a list, and the next element is an item of the same type
  defp consolidate_list_items(
    [list = %Block.List{type: type, blocks: items},
     item = %Block.ListItem{type: type} | rest], result)
  do
    start = extract_start(item)
    items = [ item | items ]   # original list is reversed
    consolidate_list_items([ %{ list | blocks: items, start: start } | rest ], result)
  end
  # We have an item, but no open list
  defp consolidate_list_items([ item = %Block.ListItem{type: type} | rest], result) do
    start = extract_start(item)
    consolidate_list_items([ %Block.List{ type: type, blocks: [ item ], start: start} | rest ], result)
  end
  # Nothing to see here, move on
  defp consolidate_list_items([ head | rest ], result) do
    consolidate_list_items(rest, [ head | result ])
  end

  defp compute_list_spacing( list = %Block.List{blocks: items} ) do
    with spaced = any_spaced_items?(items),
         unified_items = Enum.map(items, &(%{&1 | spaced: spaced}))
    do
      %{list | blocks: unified_items}
    end
  end
  defp compute_list_spacing( anything_else ), do: anything_else # nop

  defp any_spaced_items?([]), do: false
  defp any_spaced_items?([%{spaced: true}|_]), do: true
  defp any_spaced_items?([_|tail]), do: any_spaced_items?(tail)


  ##################################################
  # Read in a table (consecutive TableLines with
  # the same number of columns)

  defp read_table([ %Line.TableLine{columns: cols} | rest ],
                    col_count,
                    table = %Block.Table{})
  when length(cols) == col_count
  do
    read_table(rest, col_count, update_in(table.rows, &[ cols | &1 ]))
  end

  defp read_table( rest, col_count, %Block.Table{rows: rows}) do
    rows  = Enum.reverse(rows)
    table = Block.Table.new_for_columns(col_count)
    table = case look_for_alignments(rows) do
      nil    -> %Block.Table{table | rows: rows }
      aligns -> %Block.Table{table | alignments: aligns,
                               header:     hd(rows),
                               rows:       tl(tl(rows)) }
    end
    { table , [%Line.Blank{lnb: 0} |rest] }
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


  #####################################################
  # Traverse the block list and build a list of links #
  #####################################################

  defp links_from_blocks(blocks) do
    visit(blocks, Map.new, &link_extractor/2)
  end

  defp link_extractor(item = %Block.IdDef{id: id}, result) do
    Map.put(result, String.downcase(id), item)
  end

  defp link_extractor(_, result), do: result


  ##################################
  # Visitor pattern for each block #
  ##################################

  defp visit([], result, _func), do: result

  # Structural node BlockQuote -> descend
  defp visit([ item = %Block.BlockQuote{blocks: blocks} | rest], result, func) do
    result = func.(item, result)
    result = visit(blocks, result, func)
    visit(rest, result, func)
  end

  # Structural node List -> descend
  defp visit([ item = %Block.List{blocks: blocks} | rest], result, func) do
    result = func.(item, result)
    result = visit(blocks, result, func)
    visit(rest, result, func)
  end

  # Structural node ListItem -> descend
  defp visit([ item = %Block.ListItem{blocks: blocks} | rest], result, func) do
    result = func.(item, result)
    result = visit(blocks, result, func)
    visit(rest, result, func)
  end

  # Leaf, leaf it alone
  defp visit([ item | rest], result, func) do
    result = func.(item, result)
    visit(rest, result, func)
  end

  ###################################################################
  # Consume HTML, taking care of nesting. Assumes one tag per line. #
  ###################################################################

  defp html_match_to_closing(opener, rest), do: find_closing_tags([opener], rest, [opener])

  # No more open tags, happy case
  defp find_closing_tags([], rest, html_lines), do: {html_lines, rest, []}

  # run out of input, unhappy case
  defp find_closing_tags(needed, [], html_lines), do: {html_lines, [], needed}

  # still more lines, still needed closing
  defp find_closing_tags(needed = [needed_hd|needed_tl], [rest_hd|rest_tl], html_lines) do
    cond do
      closes_tag?(rest_hd, needed_hd) -> find_closing_tags(needed_tl, rest_tl, [rest_hd|html_lines])
      opens_tag?(rest_hd)             -> find_closing_tags([rest_hd|needed], rest_tl, [rest_hd|html_lines])
      true                            -> find_closing_tags(needed, rest_tl, [rest_hd|html_lines])
    end
  end

  ##################
  # Plugin related #
  ##################

  defp collect_plugin_lines(lines, prefix, result)
  defp collect_plugin_lines([], _, result), do: {Enum.reverse(result), []}
  defp collect_plugin_lines([%Line.Plugin{prefix: prefix, content: content, lnb: lnb} | rest], prefix, result),
    do: collect_plugin_lines(rest, prefix, [{content, lnb} | result])
  defp collect_plugin_lines( lines, _, result ), do: {Enum.reverse(result), lines}

  ###########
  # Helpers #
  ###########

  defp closes_tag?(%Line.HtmlCloseTag{tag: ctag}, %Line.HtmlOpenTag{tag: otag}), do: ctag == otag
  defp closes_tag?(_, _), do: false

  defp opens_tag?(%Line.HtmlOpenTag{}), do: true
  defp opens_tag?(_), do: false


  # (_,{'nil' | binary(),number()}) -> #{}jj
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

  defp extract_start(%{bullet: "1."}), do: ""
  defp extract_start(%{bullet: bullet}) do
    case Regex.run(~r{^(\d+)\.}, bullet) do
      nil -> ""
      [_, start] -> ~s{ start="#{start}"}
    end
  end

  defp remove_trailing_blank_lines(lines) do
    lines
    |> Enum.reverse
    |> Enum.drop_while(&blank?/1)
    |> Enum.reverse
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
