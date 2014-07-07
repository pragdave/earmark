defmodule Earmark.Line do

  alias Earmark.Helpers

  @moduledoc """
  Give a line of text, return its context-free type.
  """

  # This is the re that matches the ridiculous "[id]: url title" syntax

  @id_title_part ~S"""
        (?|
             " ([^"]*)  "         # in quotes
          |  ' ([^']*)  '         # 
          | \( ([^)]*) \)         # in parens
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

  defmodule Blank,        do: defstruct line: "", content: ""
  defmodule Ruler,        do: defstruct line: "", type: "- or * or _"
  defmodule Heading,      do: defstruct line: "", level: 1, content: "inline text"
  defmodule BlockQuote,   do: defstruct line: "", content: "text"
  defmodule Indent,       do: defstruct line: "", level: 0, content: "text"
  defmodule Fence,        do: defstruct line: "", delimiter: "~ or `", language: nil 
  defmodule HtmlOpenTag,  do: defstruct line: "", tag: "", content: ""
  defmodule HtmlCloseTag, do: defstruct line: "", tag: "<... to eol"
  defmodule HtmlComment,  do: defstruct line: "", complete: true
  defmodule IdDef,        do: defstruct line: "", id: nil, url: nil, title: nil
  defmodule ListItem,     do: defstruct type: :ul, line: "", 
                                        bullet: "* or -", content: "text"
  defmodule SetextUnderlineHeading, 
                          do: defstruct line: "", level: 1
  defmodule Text,         do: defstruct line: "", content: "text"


  @doc false
  # We want to add the original source line into every 
  # line we generate. We also need to expand tabs before 
  # proceeding

  def type_of(line) do
    line = line |> Helpers.expand_tabs |> Helpers.remove_line_ending
    %{ _type_of(line) | line: line }
  end

  def matches_id_title(content) do
    case Regex.run(@id_title_part_re, content) do
      [ _, title ] -> title
      _            -> nil
    end
  end

  defp _type_of(line) do
    cond do
      line =~ ~r/^\s*$/ ->
        %Blank{}

      line =~ ~r/^ \s{0,3} ( <! (?: -- .*? -- \s* )+ > ) $/x ->
        %HtmlComment{complete: true}

      line =~ ~r/^ \s{0,3} ( <!-- .*? ) $/x ->
        %HtmlComment{complete: false}

      line =~ ~r/^(?:- ?){3,}/ -> 
        %Ruler{type: "-" }

      line =~ ~r/^(?:\* ?){3,}/ ->
        %Ruler{type: "*" }

      line =~ ~r/^(?:_ ?){3,}/ ->
        %Ruler{type: "_" }

      match = Regex.run(~R/^(#{1,6})\s+(?|([^#]+)#*$|(.*))/, line) -> 
        [ _, level, heading ] = match
        %Heading{level: String.length(level), content: String.strip(heading) }

      match = Regex.run(~r/^>\s(.*)/, line) ->
        [ _, quote ] = match
        %BlockQuote{content: quote }

      match = Regex.run(~r/^((?:\s\s\s\s)+)(.*)/, line) ->
        [ _, spaces, code ] = match
        %Indent{level: div(String.length(spaces), 4), content: code }

      match = Regex.run(~r/^(```|~~~)\s*(\S*)/, line) ->
        [ _, fence, language ] = match
        %Fence{delimiter: fence, language: language}

      match = Regex.run(~r/^<([-\w]+)/, line) ->
        [ _, tag ] = match
        %HtmlOpenTag{tag: tag, content: line}

      match = Regex.run(~r/^<\/([-\w]+)/, line) ->
        [ _, tag ] = match
        %HtmlCloseTag{tag: tag }

      match = Regex.run(@id_re, line) -> 
        [ _, id, url | title ] = match
        title = if(length(title) == 0, do: "", else: hd(title))
        %IdDef{id: id, url: url, title: title }

      match = Regex.run(~r/^([-*+])\s+(.*)/, line) ->
        [ _, bullet, text ] = match
        %ListItem{type: :ul, bullet: bullet, content: text }

      match = Regex.run(~r/^(\d+\.)\s+(.*)/, line) ->
        [ _, bullet, text ] = match
        %ListItem{type: :ol, bullet: bullet, content: text }

      match = Regex.run(~r/^(=|-)+\s*$/, line) ->
        [ _, type ] = match
        level = if(String.starts_with?(type, "="), do: 1, else: 2)
        %SetextUnderlineHeading{level: level }

      true ->  
        %Text{content: line }
    end
  end                                               
  
end