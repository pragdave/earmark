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
  $
  '''x

#'

  defmodule Blank,        do: defstruct line: "", content: "", inside_code: false
  defmodule Ruler,        do: defstruct line: "", type: "- or * or _", inside_code: false
  defmodule Heading,      do: defstruct line: "", level: 1, content: "inline text", inside_code: false
  defmodule BlockQuote,   do: defstruct line: "", content: "text", inside_code: false
  defmodule Indent,       do: defstruct line: "", level: 0, content: "text", inside_code: false
  defmodule Fence,        do: defstruct line: "", delimiter: "~ or `", language: nil , inside_code: false
  defmodule HtmlOpenTag,  do: defstruct line: "", tag: "", content: "", inside_code: false
  defmodule HtmlCloseTag, do: defstruct line: "", tag: "<... to eol", inside_code: false
  defmodule HtmlComment,  do: defstruct line: "", complete: true, inside_code: false
  defmodule HtmlOneLine,  do: defstruct line: "", tag: "", content: "", inside_code: false
  defmodule IdDef,        do: defstruct line: "", id: nil, url: nil, title: nil, inside_code: false
  defmodule FnDef,        do: defstruct line: "", id: nil, content: "text", inside_code: false
  defmodule ListItem,     do: defstruct type: :ul, line: "",
                                        bullet: "* or -", content: "text",
                                        initial_indent: 0, inside_code: false
  defmodule SetextUnderlineHeading,
                          do: defstruct line: "", level: 1, inside_code: false, inside_code: false
  defmodule TableLine,    do: defstruct line: "", content: "", columns: 0, inside_code: false
  defmodule Ial,          do: defstruct line: "", attrs:   "", inside_code: false
  defmodule Text,         do: defstruct line: "", content: "", inside_code: false


  @doc false
  # We want to add the original source line into every
  # line we generate. We also need to expand tabs before
  # proceeding

  def type_of(line, recursive)
  when is_boolean(recursive), do: type_of(line, %Earmark.Options{}, recursive)

  def type_of(line, options = %Earmark.Options{}, recursive) do
    line = line |> Helpers.expand_tabs |> Helpers.remove_line_ending
    %{ _type_of(line, options, recursive) | line: line }
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
        %Heading{level: String.length(level), content: String.strip(heading) }

      match = Regex.run(~r/^>(?|(\s*)$|\s(.*))/, line) ->
        [ _, quote ] = match
        %BlockQuote{content: quote }

      match = Regex.run(~r/^((?:\s\s\s\s)+)(.*)/, line) ->
        [ _, spaces, code ] = match
        %Indent{level: div(String.length(spaces), 4), content: code }

      match = Regex.run(~r/^\s*(```|~~~)\s*(\w*)\s*$/, line) ->
        [ _, fence, language ] = match
        %Fence{delimiter: fence, language: language}

      (match = Regex.run(~r{^<hr(\s|>|/).*}, line)) && !recursive ->
        %HtmlOneLine{tag: "hr", content: line}

      (match = Regex.run(~r{^<([-\w]+?)(?:\s.*)?>.*</\1>}, line)) && !recursive ->
        [ _, tag ] = match
        %HtmlOneLine{tag: tag, content: line}

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
               |> String.strip
               |> String.strip(?|)
        columns = split_table_columns(body)
        %TableLine{content: line, columns: columns}

      line =~ ~r/ \s \| \s /x ->
        columns = split_table_columns(line)
        %TableLine{content: line, columns: columns}

      match = Regex.run(~r/^(=|-)+\s*$/, line) ->
        [ _, type ] = match
        level = if(String.starts_with?(type, "="), do: 1, else: 2)
        %SetextUnderlineHeading{level: level }

      match = Regex.run(~r<^\s{0,3}{:\s*([^}]+)}\s*$>, line) ->
        [ _, ial ] = match
        %Ial{attrs: String.strip(ial)}

      true ->
        %Text{content: line }
    end
  end

  defp split_table_columns(line) do
    line
    |> String.split(~r{(?<!\\)\|})
    |> Enum.map(&String.strip/1)
    |> Enum.map(fn col -> Regex.replace(~r{\\\|}, col, "|") end)
  end

end
