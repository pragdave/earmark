defmodule Earmark.Line do


  @moduledoc """
  Give a line of text, return its context-free type.
  """

  # This is the re that matches the ridiculous "[id]: url title" syntax
  @id_re ~R'''
     ^\s{0,3}             # leading spaces
     \[([^\]]*)\]:        # [someid]:
     \s+
     (?| 
         < (\S+) >          # url in <>s
       |   (\S+)            # or without
     )
     (?:
        \s+                   # optional title
        (?|
             " ([^"]*)  "         # in quotes
          |  ' ([^']*)  '         # 
          | \( ([^)]*) \)         # in parens
        )
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
  defmodule IdDef,        do: defstruct line: "", id: nil, url: nil, title: nil
  defmodule UlItem,       do: defstruct line: "", bullet: "* or -", content: "text"
  defmodule OlItem,       do: defstruct line: "", bullet: "* or -", content: "text"
  defmodule SetextUnderlineHeading, 
                          do: defstruct line: "", level: 1
  defmodule Text,         do: defstruct line: "", content: "text"

  def type_of(line) do
    %{ _type_of(line) | line: line }
  end

  def _type_of(line) do
    cond do
      line =~ ~r/^\s*$/ ->
        %Blank{}

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
        %UlItem{bullet: bullet, content: text }

      match = Regex.run(~r/^(\d+\.)\s+(.*)/, line) ->
        [ _, bullet, text ] = match
        %OlItem{bullet: bullet, content: text }

      match = Regex.run(~r/^(=|-)+\s*$/, line) ->
        [ _, type ] = match
        level = if(String.starts_with?(type, "="), do: 1, else: 2)
        %SetextUnderlineHeading{level: level }

      true ->  
        %Text{content: line }
    end
  end                                               
  
end