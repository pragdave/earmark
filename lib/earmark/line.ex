defmodule Earmark.Line do

  alias Earmark.Helpers

  @moduledoc """
  Give a line of text, return its context-free type. Not for external consumption
  """

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
#'


  defmodule Blank,        do: defstruct lnb: 0, line: "", content: "", inside_code: false
  defmodule Ruler,        do: defstruct lnb: 0, line: "", type: "- or * or _", inside_code: false
  defmodule Heading,      do: defstruct lnb: 0, line: "", level: 1, content: "inline text", inside_code: false
  defmodule BlockQuote,   do: defstruct lnb: 0, line: "", content: "text", inside_code: false
  defmodule Indent,       do: defstruct lnb: 0, line: "", level: 0, content: "text", inside_code: false
  defmodule Fence,        do: defstruct lnb: 0, line: "", delimiter: "~ or `", language: nil , inside_code: false
  defmodule HtmlOpenTag,  do: defstruct lnb: 0, line: "", tag: "", content: "", inside_code: false
  defmodule HtmlCloseTag, do: defstruct lnb: 0, line: "", tag: "<... to eol", inside_code: false
  defmodule HtmlComment,  do: defstruct lnb: 0, line: "", complete: true, inside_code: false
  defmodule HtmlOneLine,  do: defstruct lnb: 0, line: "", tag: "", content: "", inside_code: false
  defmodule IdDef,        do: defstruct lnb: 0, line: "", id: nil, url: nil, title: nil, inside_code: false
  defmodule FnDef,        do: defstruct lnb: 0, line: "", id: nil, content: "text", inside_code: false
  defmodule ListItem,     do: defstruct lnb: 0, type: :ul, line: "",
                                        bullet: "* or -", content: "text",
                                        initial_indent: 0, inside_code: false
  defmodule SetextUnderlineHeading,
                          do: defstruct lnb: 0, line: "", level: 1, inside_code: false, inside_code: false
  defmodule TableLine,    do: defstruct lnb: 0, line: "", content: "", columns: 0, inside_code: false
  defmodule Ial,          do: defstruct lnb: 0, line: "", attrs:   "", inside_code: false, verbatim: ""
  defmodule Text,         do: defstruct lnb: 0, line: "", content: "", inside_code: false

  defmodule Plugin,       do: defstruct lnb: 0, line: "", content: "", prefix: "$$"

  @type t :: %Blank{} | %Ruler{} | %Heading{} | %BlockQuote{} | %Indent{} | %Fence{} | %HtmlOpenTag{} | %HtmlCloseTag{} | %HtmlComment{} | %HtmlOneLine{} | %IdDef{} | %FnDef{} | %ListItem{} | %SetextUnderlineHeading{} | %TableLine{} | %Ial{} | %Text{} | %Plugin{}

  @type ts :: list(t)
  @doc false
  # We want to add the original source line into every
  # line we generate. We also need to expand tabs before
  # proceeding

  # (_,atom() | tuple() | #{},_) -> ['Elixir.B']
  def scan_lines lines, options \\ %Earmark.Options{}, recursive \\ false
  def scan_lines lines, options, recursive do
    lines_with_count( lines, options.line - 1)
    |> Earmark.pmap( fn (line) ->  type_of(line, options, recursive) end)
  end

  defp lines_with_count lines, offset do
    Enum.zip lines, offset..(offset+Enum.count(lines))
  end

  def type_of(line, recursive)
  when is_boolean(recursive), do: type_of(line, %Earmark.Options{}, recursive)

  def type_of({line, lnb}, options = %Earmark.Options{}, recursive) do
    line = line |> Helpers.expand_tabs |> Helpers.remove_line_ending
    %{ _type_of(line, options, recursive) | line: line, lnb: lnb }
  end

  @doc false
  # Used by the block parser to test if a line following an IdDef
  # is a possible title
  def matches_id_title(content) do
    case Regex.run(@id_title_part_re, content) do
      [ _, title ] -> title
      _            -> nil
    end
  end

  defp _type_of(line, options=%Earmark.Options{}, recursive) do
    cond do
      line =~ ~r/^\s*$/ ->
        %Blank{}

      line =~ ~r/^ \s{0,3} ( <! (?: -- .*? -- \s* )+ > ) $/x && !recursive ->
        %HtmlComment{complete: true}

      line =~ ~r/^ \s{0,3} ( <!-- .*? ) $/x && !recursive ->
        %HtmlComment{complete: false}

      line =~ ~r/^ \s{0,3} (?:-\s?){3,} $/x ->
        %Ruler{type: "-" }

      line =~ ~r/^ \s{0,3} (?:\*\s?){3,} $/x ->
        %Ruler{type: "*" }

      line =~ ~r/^ \s{0,3} (?:_\s?){3,} $/x ->
        %Ruler{type: "_" }

      match = Regex.run(~R/^(#{1,6})\s+(?|([^#]+)#*$|(.*))/u, line) ->
        [ _, level, heading ] = match
        %Heading{level: String.length(level), content: String.trim(heading) }

      match = Regex.run(~r/^>(?|(\s*)$|\s(.*))/, line) ->
        [ _, quote ] = match
        %BlockQuote{content: quote }

      match = Regex.run(~r/^((?:\s\s\s\s)+)(.*)/, line) ->
        [ _, spaces, code ] = match
        %Indent{level: div(String.length(spaces), 4), content: code }

      match = Regex.run(~r/^\s*(```|~~~)\s*([\w\-]*)\s*$/u, line) ->
        [ _, fence, language ] = match
        %Fence{delimiter: fence, language: language}

      #   Although no block tags I still think they should close a preceding para as do many other
      #   implementations.
      (match = Regex.run(@void_tag_rgx, line)) && !recursive ->
        [ _, tag ] = match

        %HtmlOneLine{tag: tag, content: line}

      (match = Regex.run(~r{^<([-\w]+?)(?:\s.*)?>.*</\1>}, line)) && !recursive ->
        [ _, tag ] = match
          if block_tag?(tag), do: %HtmlOneLine{tag: tag, content: line},
            else: %Text{content: line}

      (match = Regex.run(~r{^<([-\w]+?)(?:\s.*)?/>.*}, line)) && !recursive ->
        [ _, tag ] = match
          if block_tag?(tag), do: %HtmlOneLine{tag: tag, content: line},
            else: %Text{content: line}

      (match = Regex.run(~r/^<([-\w]+?)(?:\s.*)?>/, line)) && !recursive ->
        [ _, tag ] = match
        %HtmlOpenTag{tag: tag, content: line}

      (match = Regex.run(~r/^<\/([-\w]+?)>/, line)) && !recursive ->
        [ _, tag ] = match
        %HtmlCloseTag{tag: tag}

      match = Regex.run(@id_re, line) ->
        [ _, id, url | title ] = match
        title = if(length(title) == 0, do: "", else: hd(title))
        %IdDef{id: id, url: url, title: title }

      match = options.footnotes && Regex.run(~r/^\[\^([^\s\]]+)\]:\s+(.*)/, line) ->
        [ _, id, first_line ] = match
        %FnDef{id: id, content: first_line }

      match = Regex.run(~r/^(\s{0,3})([-*+])\s+(.*)/, line) ->
        [ _, leading, bullet, text ] = match
        %ListItem{type:          :ul,
                  bullet:         bullet,
                  content:        text,
                  initial_indent: String.length(leading) }

      match = Regex.run(~r/^(\s{0,3})(\d+\.)\s+(.*)/, line) ->
        [ _, leading, bullet, text ] = match
        %ListItem{type: :ol,
                  bullet: bullet,
                  content: text,
                  initial_indent: String.length(leading) }

      match = Regex.run(~r/^ \s{0,3} \| (?: [^|]+ \|)+ \s* $ /x, line) ->
        [ body ] = match
        body = body
               |> String.trim
               |> String.trim("|")
        columns = split_table_columns(body)
        %TableLine{content: line, columns: columns}

      line =~ ~r/ \s \| \s /x ->
        columns = split_table_columns(line)
        %TableLine{content: line, columns: columns}

      match = Regex.run(~r/^(=|-)+\s*$/, line) ->
        [ _, type ] = match
        level = if(String.starts_with?(type, "="), do: 1, else: 2)
        %SetextUnderlineHeading{level: level }

      match = Regex.run(~r<^\s{0,3}{:(\s*[^}]+)}\s*$>, line) ->
        [ _, ial ] = match
        %Ial{attrs: String.trim(ial), verbatim: ial}

      match = Regex.run(~r<^\$\$(\w*)$>, line) ->
        [_, prefix] = match
        %Plugin{ content: "", prefix: prefix }

      match = Regex.run(~r<^\$\$(\w*)\s(.*)$>, line) ->
        [_, prefix, content] = match
        %Plugin{ content: content, prefix: prefix }

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
        %Text{content: line }
    end
  end


  @block_tags ~w< address article aside blockquote canvas dd div dl fieldset figcaption h1 h2 h3 h4 h5 h6 header hgroup li main nav noscript ol output p pre section table tfoot ul video> |>
    Enum.into( MapSet.new() )
  defp block_tag?(tag), do: MapSet.member?(@block_tags, tag)

  defp split_table_columns(line) do
    line
    |> String.split(~r{(?<!\\)\|})
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn col -> Regex.replace(~r{\\\|}, col, "|") end)
  end

end

# SPDX-License-Identifier: Apache-2.0
