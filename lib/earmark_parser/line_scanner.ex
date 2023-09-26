defmodule Earmark.Parser.LineScanner do
  @moduledoc false

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
  @doc false
  def void_tag?(tag), do: Regex.match?(@void_tag_rgx, "<#{tag}>")

  def scan_lines(lines, options, recursive) do
    _lines_with_count(lines, options.line - 1)
    |> _with_lookahead(options, recursive)
  end

  def type_of(line, recursive)
      when is_boolean(recursive),
      do: type_of(line, %Options{}, recursive)

  def type_of({line, lnb}, options = %Options{annotations: annotations}, recursive) when is_binary(line) do
    {line1, annotation} = line |> Helpers.expand_tabs() |> Helpers.remove_line_ending(annotations)
    %{_type_of(line1, options, recursive) | annotation: annotation, lnb: lnb}
  end

  def type_of({line, lnb}, _, _) do
    raise ArgumentError, "line number #{lnb} #{inspect line} is not a binary"
  end

  defp _type_of(line, options = %Options{}, recursive) do
    {ial, stripped_line} = Helpers.extract_ial(line)
    {content, indent} = _count_indent(line, 0)
    lt_four? = indent < 4

    cond do
      content == "" ->
        _create_text(line, content, indent)

      lt_four? && !recursive && Regex.run(~r/\A <! (?: -- .*? -- \s* )+ > \z/x, content) ->
        %Line.HtmlComment{complete: true, indent: indent, line: line}

      lt_four? && !recursive && Regex.run(~r/\A <!-- .*? \z/x, content) ->
        %Line.HtmlComment{complete: false, indent: indent, line: line}

      lt_four? && Regex.run(~r/^ (?:-\s?){3,} $/x, content) ->
        %Line.Ruler{type: "-", indent: indent, line: line}

      lt_four? && Regex.run(~r/^ (?:\*\s?){3,} $/x, content) ->
        %Line.Ruler{type: "*", indent: indent, line: line}

      lt_four? && Regex.run(~r/\A (?:_\s?){3,} \z/x, content) ->
        %Line.Ruler{type: "_", indent: indent, line: line}

      match = Regex.run(~R/^(#{1,6})\s+(?|(.*?)\s*#*\s*$|(.*))/u, stripped_line) ->
        [_, level, heading] = match

        %Line.Heading{
          level: String.length(level),
          content: String.trim(heading),
          indent: 0,
          ial: ial,
          line: line
        }

      match = lt_four? && Regex.run(~r/\A>\s?(.*)/, content) ->
        [_, quote] = match
        %Line.BlockQuote{content: quote, indent: indent, ial: ial, line: line}

      match = Regex.run(@indent_re, line) ->
        [_, spaces, more_spaces, rest] = match
        sl = byte_size(spaces)

        %Line.Indent{
          level: div(sl, 4),
          content: more_spaces <> rest,
          indent: byte_size(more_spaces) + sl,
          line: line
        }

      match = Regex.run(~r/\A(\s*)(`{3,}|~{3,})\s*([^`\s]*)\s*\z/u, line) ->
        [_, leading, fence, language] = match

        %Line.Fence{
          delimiter: fence,
          language: _attribute_escape(language),
          indent: byte_size(leading),
          line: line
        }

      # Although no block tags I still think they should close a preceding para as do many other
      # implementations.
      match = !recursive && Regex.run(@void_tag_rgx, line) ->
        [_, tag] = match
        %Line.HtmlOneLine{tag: tag, content: line, indent: 0, line: line}

      match = !recursive && Regex.run(~r{\A<([-\w]+?)(?:\s.*)?>.*</\1>}, line) ->
        [_, tag] = match
        %Line.HtmlOneLine{tag: tag, content: line, indent: 0, line: line}

      match = !recursive && Regex.run(~r{\A<([-\w]+?)(?:\s.*)?/>.*}, line) ->
        [_, tag] = match
        %Line.HtmlOneLine{tag: tag, content: line, indent: 0, line: line}

      match = !recursive && Regex.run(~r/\A < ([-\w]+?) (?:\s.*)? >/x, line) ->
        [_, tag] = match
        %Line.HtmlOpenTag{tag: tag, content: line, indent: 0, line: line}

      match = lt_four? && !recursive && Regex.run(~r/\A<\/([-\w]+?)>/, content) ->
        [_, tag] = match
        %Line.HtmlCloseTag{tag: tag, indent: indent, line: line}

      match = lt_four? && Regex.run(@id_re, content) ->
        [_, id, url | title] = match
        title = if(length(title) == 0, do: "", else: hd(title))
        %Line.IdDef{id: id, url: url, title: title, indent: indent, line: line}

      match = options.footnotes && Regex.run(~r/\A\[\^([^\s\]]+)\]:\s+(.*)/, line) ->
        [_, id, first_line] = match
        %Line.FnDef{id: id, content: first_line, indent: 0, line: line}

      match = lt_four? && Regex.run(~r/^([-*+])\s(\s*)(.*)/, content) ->
        [_, bullet, spaces, text] = match

        %Line.ListItem{
          type: :ul,
          bullet: bullet,
          content: spaces <> text,
          indent: indent,
          list_indent: String.length(bullet <> spaces) + indent + 1,
          line: line
        }

      match = lt_four? && Regex.run(~r/^(\d{1,9}[.)])\s(\s*)(.*)/, content) ->
        _create_list_item(match, indent, line)

      match = Regex.run(~r/^ \| (?: [^|]+ \|)+ \s* $ /x, content) ->
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

      line |> String.replace(~r/\[\[ .*? \]\]/x, "") |> String.match?(~r/\A (\s*) .* \s \| \s /x) ->
        columns = _split_table_columns(line)

        %Line.TableLine{
          content: line,
          columns: columns,
          is_header: _determine_if_header(columns),
          indent: indent,
          line: line
        }

      options.gfm_tables && line |> String.replace(~r/\[\[ .*? \]\]/x, "") |> String.match?(~r/\A (\s*) .* \| /x) ->
        columns = _split_table_columns(line)

        %Line.TableLine{
          content: line,
          columns: columns,
          is_header: _determine_if_header(columns),
          needs_header: true,
          indent: indent,
          line: line
        }

      match = Regex.run(~r/^(=|-)+\s*$/, line) ->
        [_, type] = match
        level = if(String.starts_with?(type, "="), do: 1, else: 2)
        %Line.SetextUnderlineHeading{level: level, indent: 0, line: line}

      match = lt_four? && Regex.run(~r<^{:(\s*[^}]+)}\s*$>, content) ->
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

  defp _create_list_item([_, bullet, spaces, text], indent, line) do
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

  defp _create_text(line) do
    {content, indent} = _count_indent(line, 0)
    _create_text(line, content, indent)
  end

  defp _create_text(line, "", indent),
    do: %Line.Blank{indent: indent, line: line}

  defp _create_text(line, content, indent),
    do: %Line.Text{content: content, indent: indent, line: line}

  defp _count_indent(<<space, rest::binary>>, indent) when space in [?\s, ?\t],
    do: _count_indent(rest, indent + 1)

  defp _count_indent(rest, indent),
    do: {rest, indent}

  defp _lines_with_count(lines, offset) do
    Enum.zip(lines, offset..(offset + Enum.count(lines)))
  end

  defp _with_lookahead([line_lnb | lines], options, recursive) do
    case type_of(line_lnb, options, recursive) do
      %Line.Fence{delimiter: delimiter, indent: 0} = fence ->
        stop = ~r/\A (\s*) (?: #{delimiter} ) \s* ([^`\s]*) \s* \z/xu
        [fence | _lookahead_until_match(lines, stop, options, recursive)]

      %Line.HtmlComment{complete: false} = html_comment ->
        [html_comment | _lookahead_until_match(lines, ~r/-->/u, options, recursive)]

      other ->
        [other | _with_lookahead(lines, options, recursive)]
    end
  end

  defp _with_lookahead([], _options, _recursive), do: []

  defp _lookahead_until_match([], _, _, _), do: []

  defp _lookahead_until_match([{line, lnb} | lines], regex, options, recursive) do
    if line =~ regex do
      [type_of({line, lnb}, options, recursive) | _with_lookahead(lines, options, recursive)]
    else
      [
        %{_create_text(line) | lnb: lnb}
        | _lookahead_until_match(lines, regex, options, recursive)
      ]
    end
  end

  @column_rgx ~r{\A[\s|:-]+\z}
  defp _determine_if_header(columns) do
    columns
    |> Enum.all?(fn col -> Regex.run(@column_rgx, col) end)
  end

  defp _split_table_columns(line) do
    line
    |> String.split(~r{(?<!\\)\|})
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn col -> Regex.replace(~r{\\\|}, col, "|") end)
  end
end

#  SPDX-License-Identifier: Apache-2.0
