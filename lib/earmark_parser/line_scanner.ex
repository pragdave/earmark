defmodule Earmark.Parser.LineScanner do
  @moduledoc false
  require Logger
  alias Earmark.Parser.{Helpers, Line, Options}

  # This is the re that matches the ridiculous "[id]: url title" syntax

  @id_title_part ~S"""
        (?|
             " (.*)  "         # in quotes
          |  ' (.*)  '         #
          | \( (.*) \)         # in parens
        )
  """

  @id_re ~r'''
     ^\[([^^].*?)\]:            # [someid]:
     \s+
     (?|
         < (\S+) >          # url in <>s
       |   (\S+)            # or without
     )
     (?:
        \s+                   # optional title
        #{@id_title_part}
     )?
     \s*
  $
  '''x

  @indent_re ~r'''
    \A ( (?: \s{4})+ ) (\s*)                       # 4 or more leading spaces
    (.*)                                  # the rest
  '''x

  @void_tags ~w{area br hr img wbr}
  @void_tag_rgx ~r'''
      ^<( #{Enum.join(@void_tags, "|")} )
        .*?
        >
  '''x

  @rgx_map %{
    block_quote: ~r/\A>\s?(.*)/,
    column_rgx: ~r{\A[\s|:-]+\z},
    comment_rest: ~r/(<!--.*?-->)(.*)/,
    fence: ~r/\A(\s*)(`{3,}|~{3,})\s*([^`\s]*)\s*\z/u,
    footnote_definition: ~r/\A\[\^([^\s\]]+)\]:\s+(.*)/,
    heading: ~r/^(\#{1,6})\s+(?|(.*?)\s*#*\s*$|(.*))/u,
    html_close_tag: ~r/\A<\/([-\w]+?)>/,
    html_comment_complete: ~r/\A <! (?: -- .*? -- \s* )+ > \z/x,
    html_comment_start: ~r/\A <!-- .*? \z/x,
    html_one_line: ~r{\A<([-\w]+?)(?:\s.*)?>.*</\1>},
    html_open_tag: ~r/\A < ([-\w]+?) (?:\s.*)? >/x,
    html_self_closing_tag: ~r{\A<([-\w]+?)(?:\s.*)?/>.*},
    ial_definition: ~r<^{:(\s*[^}]+)}\s*$>,
    id_re: @id_re,
    indent_re: @indent_re,
    list_item_ordered: ~r/^(\d{1,9}[.)])\s(\s*)(.*)/,
    list_item_unordered: ~r/^([-*+])\s(\s*)(.*)/,
    ruler_dash: ~r/^ (?:-\s?){3,} $/x,
    ruler_star: ~r/^ (?:\*\s?){3,} $/x,
    ruler_underscore: ~r/\A (?:_\s?){3,} \z/x,
    setext_heading: ~r/^(=|-)+\s*$/,
    table_line: ~r/^ \| (?: [^|]+ \|)+ \s* $ /x,
    table_line_gfm: ~r/\A (\s*) .* \| /x,
    table_line_prefix_space: ~r/\A (\s*) .* \s \| \s /x,
    void_tag: @void_tag_rgx,
    wiki_link: ~r/\[\[ .*? \]\]/x
  }
  @doc false
  def void_tag?(tag), do: Regex.match?(@void_tag_rgx, "<#{tag}>")

  def scan_lines(lines, options, recursive) do
    _lines_with_count(lines, options.line - 1)
    |> _with_lookahead(options, recursive)
  end

  def type_of(line, recursive)
      when is_boolean(recursive),
      do: type_of(line, %Options{}, recursive)

  def type_of({line, lnb}, options = %Options{annotations: annotations}, recursive)
      when is_binary(line) do
    {line1, annotation} = line |> Helpers.expand_tabs() |> Helpers.remove_line_ending(annotations)
    %{_type_of(line1, options, recursive) | annotation: annotation, lnb: lnb}
  end

  def type_of({line, lnb}, _, _) do
    raise ArgumentError, "line number #{lnb} #{inspect(line)} is not a binary"
  end

  defp _type_of(line, options = %Options{}, recursive) do
    {ial, stripped_line} = Helpers.extract_ial(line)
    {content, indent} = _count_indent(line, 0)
    lt_four? = indent < 4

    cond do
      content == "" ->
        _create_text(line, content, indent)

      lt_four? && !recursive && regex_run(:html_comment_complete, content) ->
        %Line.HtmlComment{complete: true, indent: indent, line: line}

      lt_four? && !recursive && regex_run(:html_comment_start, content) ->
        %Line.HtmlComment{complete: false, indent: indent, line: line}

      lt_four? && regex_run(:ruler_dash, content) ->
        %Line.Ruler{type: "-", indent: indent, line: line}

      lt_four? && regex_run(:ruler_star, content) ->
        %Line.Ruler{type: "*", indent: indent, line: line}

      lt_four? && regex_run(:ruler_underscore, content) ->
        %Line.Ruler{type: "_", indent: indent, line: line}

      match = regex_run(:heading, stripped_line) ->
        [_, level, heading] = match

        %Line.Heading{
          level: String.length(level),
          content: String.trim(heading),
          indent: 0,
          ial: ial,
          line: line
        }

      match = lt_four? && regex_run(:block_quote, content) ->
        [_, quote] = match
        %Line.BlockQuote{content: quote, indent: indent, ial: ial, line: line}

      match = regex_run(:indent_re, line) ->
        [_, spaces, more_spaces, rest] = match
        sl = byte_size(spaces)

        %Line.Indent{
          level: div(sl, 4),
          content: more_spaces <> rest,
          indent: byte_size(more_spaces) + sl,
          line: line
        }

      match = regex_run(:fence, line) ->
        [_, leading, fence, language] = match

        %Line.Fence{
          delimiter: fence,
          language: _attribute_escape(language),
          indent: byte_size(leading),
          line: line
        }

      # Although no block tags I still think they should close a preceding para as do many other
      # implementations.
      match = !recursive && regex_run(:void_tag, line) ->
        [_, tag] = match
        %Line.HtmlOneLine{tag: tag, content: line, indent: 0, line: line}

      match = !recursive && regex_run(:html_one_line, line) ->
        [_, tag] = match
        %Line.HtmlOneLine{tag: tag, content: line, indent: 0, line: line}

      match = !recursive && regex_run(:html_self_closing_tag, line) ->
        [_, tag] = match
        %Line.HtmlOneLine{tag: tag, content: line, indent: 0, line: line}

      match = !recursive && regex_run(:html_open_tag, line) ->
        [_, tag] = match
        %Line.HtmlOpenTag{tag: tag, content: line, indent: 0, line: line}

      match = lt_four? && !recursive && regex_run(:html_close_tag, content) ->
        [_, tag] = match
        %Line.HtmlCloseTag{tag: tag, indent: indent, line: line}

      match = lt_four? && regex_run(:id_re, content) ->
        [_, id, url | title] = match
        title = if(Enum.empty?(title), do: "", else: hd(title))
        %Line.IdDef{id: id, url: url, title: title, indent: indent, line: line}

      match = options.footnotes && regex_run(:footnote_definition, line) ->
        [_, id, first_line] = match
        %Line.FnDef{id: id, content: first_line, indent: 0, line: line}

      match = lt_four? && regex_run(:list_item_unordered, content) ->
        [_, bullet, spaces, text] = match

        %Line.ListItem{
          type: :ul,
          bullet: bullet,
          content: spaces <> text,
          indent: indent,
          list_indent: String.length(bullet <> spaces) + indent + 1,
          line: line
        }

      match = lt_four? && regex_run(:list_item_ordered, content) ->
        _create_list_item(match, indent, line)

      match = regex_run(:table_line, content) ->
        [body] = match

        body =
          body
          |> String.trim()
          |> String.trim("|")

        columns = _split_table_columns(body)

        %Line.TableLine{
          content: line,
          columns: columns,
          is_header: _determine_if_header(columns),
          indent: indent,
          line: line
        }

      table_line?(line) ->
        columns = _split_table_columns(line)

        %Line.TableLine{
          content: line,
          columns: columns,
          is_header: _determine_if_header(columns),
          indent: indent,
          line: line
        }

      options.gfm_tables && table_line?(line, :gfm) ->
        columns = _split_table_columns(line)

        %Line.TableLine{
          content: line,
          columns: columns,
          is_header: _determine_if_header(columns),
          needs_header: true,
          indent: indent,
          line: line
        }

      match = regex_run(:setext_heading, line) ->
        [_, type] = match
        level = if(String.starts_with?(type, "="), do: 1, else: 2)
        %Line.SetextUnderlineHeading{level: level, indent: 0, line: line}

      match = lt_four? && regex_run(:ial_definition, content) ->
        [_, ial] = match
        %Line.Ial{attrs: String.trim(ial), verbatim: ial, indent: indent, line: line}

      true ->
        _create_text(line, content, indent)
    end
  end

  defp _attribute_escape(string),
    do:
      string
      |> String.replace("&", "&amp;")
      |> String.replace("<", "&lt;")

  defp _create_list_item(match, indent, line)

  defp _create_list_item([_, bullet, spaces, text] = match, indent, line) do
    Logger.debug(
      "Creating list item: #{inspect(match)}, indent: #{inspect(indent)}, line: #{inspect(line)}"
    )

    sl = byte_size(spaces)
    sl1 = if sl > 3, do: 1, else: sl + 1
    sl2 = sl1 + byte_size(bullet)

    %Line.ListItem{
      type: :ol,
      bullet: bullet,
      content: spaces <> text,
      indent: indent,
      list_indent: indent + sl2,
      line: line
    }
  end

  defp _create_text(line, "", indent),
    do: %Line.Blank{indent: indent, line: line}

  defp _create_text(line, content, indent),
    do: %Line.Text{content: content, indent: indent, line: line}

  defp _count_indent(<<space, rest::binary>>, indent) when space in [?\s, ?\t] do
    _count_indent(rest, indent + 1)
  end

  defp _count_indent(rest, indent) do
    {rest, indent}
  end

  defp _lines_with_count(lines, offset) do
    Enum.zip(lines, offset..(offset + Enum.count(lines)))
  end

  defp _with_lookahead([line_lnb | lines], options, recursive) do
    process_line(line_lnb, options, recursive) ++
      _with_lookahead(lines, options, recursive)
  end

  defp _with_lookahead([], _options, _recursive), do: []

  defp process_line({line, lnb}, options, recursive) do
    case regex_run(:comment_rest, line, capture: :all_but_first) do
      [comment, rest] ->
        [type_of({comment, lnb}, options, recursive)] ++
          [type_of({rest, lnb}, options, recursive)]

      nil ->
        [type_of({line, lnb}, options, recursive)]
    end
  end

  defp _determine_if_header(columns) do
    columns
    |> Enum.all?(fn col -> regex_run(:column_rgx, col) end)
  end

  defp _split_table_columns(line) do
    line
    |> String.split(~r{(?<!\\)\|})
    |> Enum.map(fn col ->
      Regex.replace(~r{\\\|}, col, "|")
      |> String.trim()
    end)
  end

  defp regex_run(key, target), do: regex_run(key, target, [])

  defp regex_run(key, target, opts) do
    @rgx_map
    |> Map.get(key)
    |> Regex.run(target, opts)
  end

  defp table_line?(line), do: table_line?(line, :none)

  defp table_line?(line, opt) do
    line
    |> String.replace(@rgx_map.wiki_link, "")
    |> case do
      line when opt in [:gfm] -> String.match?(line, @rgx_map.table_line_gfm)
      _ -> String.match?(line, @rgx_map.table_line)
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
