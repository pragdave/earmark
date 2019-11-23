defmodule Earmark.LineScanner do

  @moduledoc false
  
  alias Earmark.Helpers
  alias Earmark.Line
  alias Earmark.Options

  import Options, only: [get_mapper: 1]

  # This is the re that matches the ridiculous "[id]: url title" syntax

  @id_title_part ~S"""
        (?|
             " (.*)  "         # in quotes
          |  ' (.*)  '         #
          | \( (.*) \)         # in parens
        )
  """

  @id_title_part_re ~r[^\s*#{@id_title_part}\s*$]x

  @id_re ~r'''
     ^\s{0,3}             # leading spaces
     \[([^\]]*)\]:        # [someid]:
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

  @void_tags ~w{area br hr img wbr}
  @void_tag_rgx ~r'''
      ^<( #{Enum.join(@void_tags, "|")} )
        .*?
        >
  '''x
  @doc false
  def void_tag?(tag), do: Regex.match?(@void_tag_rgx, "<#{tag}>") 

  @doc false
  # We want to add the original source line into every
  # line we generate. We also need to expand tabs before
  # proceeding

  # (_,atom() | tuple() | #{},_) -> ['Elixir.B']
  def scan_lines(lines, options \\ %Options{}, recursive \\ false)

  def scan_lines(lines, options, recursive) do
    lines_with_count(lines, options.line - 1)
    |> get_mapper(options).(fn line -> type_of(line, options, recursive) end)
  end

  defp lines_with_count(lines, offset) do
    Enum.zip(lines, offset..(offset + Enum.count(lines)))
  end

  def type_of(line, recursive)
      when is_boolean(recursive),
      do: type_of(line, %Options{}, recursive)

  def type_of({line, lnb}, options = %Options{}, recursive) do
    line = line |> Helpers.expand_tabs() |> Helpers.remove_line_ending()
    %{_type_of(line, options, recursive) | line: line, lnb: lnb}
  end

  @doc false
  # Used by the block parser to test if a line following an IdDef
  # is a possible title
  def matches_id_title(content) do
    case Regex.run(@id_title_part_re, content) do
      [_, title] -> title
      _ -> nil
    end
  end

  defp _type_of(line, options = %Options{}, recursive) do
    cond do
      line =~ ~r/^\s*$/ ->
        %Line.Blank{}

      line =~ ~r/^ \s{0,3} ( <! (?: -- .*? -- \s* )+ > ) $/x && !recursive ->
        %Line.HtmlComment{complete: true}

      line =~ ~r/^ \s{0,3} ( <!-- .*? ) $/x && !recursive ->
        %Line.HtmlComment{complete: false}

      line =~ ~r/^ \s{0,3} (?:-\s?){3,} $/x ->
        %Line.Ruler{type: "-"}

      line =~ ~r/^ \s{0,3} (?:\*\s?){3,} $/x ->
        %Line.Ruler{type: "*"}

      line =~ ~r/^ \s{0,3} (?:_\s?){3,} $/x ->
        %Line.Ruler{type: "_"}

      match = Regex.run(~R/^(#{1,6})\s+(?|([^#]+)#*$|(.*))/u, line) ->
        [_, level, heading] = match
        %Line.Heading{level: String.length(level), content: String.trim(heading)}

      match = Regex.run(~r/\A {0,3}>(?|(\s*)$|\s(.*))/, line) ->
        [_, quote] = match
        %Line.BlockQuote{content: quote}

      match = Regex.run(~r/^((?:\s\s\s\s)+)(.*)/, line) ->
        [_, spaces, code] = match
        %Line.Indent{level: div(String.length(spaces), 4), content: code}

      match = Regex.run(~r/^\s*(`{3,}|~{3,})\s*([^`\s]*)\s*$/u, line) ->
        [_, fence, language] = match
        %Line.Fence{delimiter: fence, language: _attribute_escape(language)}

      #   Although no block tags I still think they should close a preceding para as do many other
      #   implementations.
      (match = Regex.run(@void_tag_rgx, line)) && !recursive ->
        [_, tag] = match

        %Line.HtmlOneLine{tag: tag, content: line}

      (match = Regex.run(~r{^<([-\w]+?)(?:\s.*)?>.*</\1>}, line)) && !recursive ->
        [_, tag] = match

        if block_tag?(tag),
          do: %Line.HtmlOneLine{tag: tag, content: line},
          else: %Line.Text{content: line}

      (match = Regex.run(~r{^<([-\w]+?)(?:\s.*)?/>.*}, line)) && !recursive ->
        [_, tag] = match

        if block_tag?(tag),
          do: %Line.HtmlOneLine{tag: tag, content: line},
          else: %Line.Text{content: line}

      (match = Regex.run(~r/^<([-\w]+?)(?:\s.*)?>/, line)) && !recursive ->
        [_, tag] = match
        %Line.HtmlOpenTag{tag: tag, content: line}

      (match = Regex.run(~r/^<\/([-\w]+?)>/, line)) && !recursive ->
        [_, tag] = match
        %Line.HtmlCloseTag{tag: tag}

      match = Regex.run(@id_re, line) ->
        [_, id, url | title] = match
        title = if(length(title) == 0, do: "", else: hd(title))
        %Line.IdDef{id: id, url: url, title: title}

      match = options.footnotes && Regex.run(~r/^\[\^([^\s\]]+)\]:\s+(.*)/, line) ->
        [_, id, first_line] = match
        %Line.FnDef{id: id, content: first_line}

      match = Regex.run(~r/^(\s{0,3})([-*+])(\s+)(.*)/, line) ->
        [_, leading, bullet, spaces, text] = match

        %Line.ListItem{
          type: :ul,
          bullet: bullet,
          content: text,
          initial_indent: String.length(leading),
          list_indent:  String.length(leading <> bullet <> spaces),
        }

      match = Regex.run(~r/^(\s{0,3})(\d+\.)(\s+)(.*)/, line) ->
        [_, leading, bullet, spaces, text] = match

        %Line.ListItem{
          type: :ol,
          bullet: bullet,
          content: text,
          initial_indent: String.length(leading),
          list_indent:  String.length(leading <> bullet <> spaces),
        }

      match = Regex.run(~r/^ \s{0,3} \| (?: [^|]+ \|)+ \s* $ /x, line) ->
        [body] = match

        body =
          body
          |> String.trim()
          |> String.trim("|")

        columns = split_table_columns(body)
        %Line.TableLine{content: line, columns: columns, is_header: _determine_if_header(columns)}

      line =~ ~r/ \s \| \s /x ->
        columns = split_table_columns(line)
        %Line.TableLine{content: line, columns: columns, is_header: _determine_if_header(columns)}

      line =~ ~r/ \| /x && options.gfm_tables ->
        columns = split_table_columns(line)
        %Line.TableLine{content: line, columns: columns, is_header: _determine_if_header(columns), needs_header: true}

      match = Regex.run(~r/^(=|-)+\s*$/, line) ->
        [_, type] = match
        level = if(String.starts_with?(type, "="), do: 1, else: 2)
        %Line.SetextUnderlineHeading{level: level}

      match = Regex.run(~r<^\s{0,3}{:(\s*[^}]+)}\s*$>, line) ->
        [_, ial] = match
        %Line.Ial{attrs: String.trim(ial), verbatim: ial}

      # Hmmmm in case of perf problems
      # Assuming that text lines are the most frequent would it not boost performance (which seems to be good anyway)
      # it would be great if we could come up with a regex that is a superset of all the regexen above and then
      # we could match as follows
      #       
      #       cond 
      #       nil = Regex.run(superset, line) -> %Text
      #       ...
      #       # all other matches from above
      #       ...
      #       # Catch the case were the supergx was too wide
      #       true -> %Text
      #
      #
      true ->
        %Line.Text{content: line}
    end
  end


  defp _attribute_escape(string), do:
    string
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")


  @block_tags ~w< address article aside blockquote canvas dd div dl fieldset figcaption h1 h2 h3 h4 h5 h6 header hgroup li main nav noscript ol output p pre section table tfoot ul video>
              |> Enum.into(MapSet.new())
  defp block_tag?(tag), do: MapSet.member?(@block_tags, tag)

  @column_rgx ~r{\A[\s|:-]+\z}
  defp _determine_if_header(columns) do
    columns
    |> Enum.all?(fn col -> Regex.run(@column_rgx, col) end)
  end
  defp split_table_columns(line) do
    line
    |> String.split(~r{(?<!\\)\|})
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn col -> Regex.replace(~r{\\\|}, col, "|") end)
  end
end
