defmodule Earmark.Scanner do

  import Earmark.Helpers.StringHelpers, only: [behead: 2]

  @backtix_rgx    ~r/\A(`+)(.*)/
  @blockquote_rgx ~r/\A>(?!\S)/
  @code_fence_rgx ~r/\A(\s*)~~~/
  @headline_rgx   ~r/\A(\#{1,6})(\s+)(.*)/
#  @id_close_rgx   ~r/\[(.*?)\](?!:)/
  @id_open_rgx    ~r/\A(\s{0,3})\[(.*?)\]:\s+(.*)\z/
  @indent_rgx     ~r/\A\s{4,}/
  @list_item_rgx  ~r/\A(\s{0,3})(\d+\.|\*|-)\s+/
  @ruler_rgx      ~r/\A \s{0,3} (?:([-_*])\s?)(?:\1\s?){2,} \z/x
  @under_l1_head_rgx ~r/\A=+\s*\z/
  @under_l2_head_rgx ~r/\A-{1,2}\s*\z/

  @text_rgx ~r/(?:[^`]|\\`)*/

  defmodule Backtix,       do: defstruct count: 1
  defmodule Blockquote,    do: defstruct []
  defmodule CodeFence,     do: defstruct []
  defmodule Headline,      do: defstruct level: 1..6
  defmodule IdClose,       do: defstruct id: "content of [...]"
  defmodule IdOpen,        do: defstruct id: "content of [...]", href: "word after ]:\\s+"
  defmodule Indent,        do: defstruct count: 4
  defmodule ListItem,      do: defstruct type: :ul_ol, bullet: "* or - or empty"
  defmodule RulerFat,      do: defstruct []
  defmodule RulerMedium,   do: defstruct []
  defmodule RulerThin,     do: defstruct []
  defmodule Text,          do: defstruct content: ""
  defmodule UnderHeadline, do: defstruct level: 1..2

  @type token :: %Backtix{} | %Blockquote{} | %CodeFence{} | %Headline{} | %IdClose{} | %IdOpen{} | %Indent{} | %ListItem{} | %RulerFat{} | %RulerMedium{} | %RulerThin{} | %Text{} | %UnderHeadline{}

  @type tokens :: list(token)
  @type t_continuation :: {token, String.t, boolean()}


  @doc """
  Scans a line into a list of tokens
  """
  def scan_line line do
    scan_line_into_tokens( line, [], true )
    |> Enum.reverse
  end

  # Empty Line
  defp scan_line_into_tokens "", [], _beg do
    []
  end
  # Line consumed
  defp scan_line_into_tokens( "", tokens, _beg), do: tokens
  # Line not consumed
  defp scan_line_into_tokens line, tokens, beg do
    {token, rest, still_at_beg} = scan_next_token( line, beg )
    scan_line_into_tokens( rest, [token|tokens], still_at_beg )
  end

  defp scan_next_token line, beg_of_line
  defp scan_next_token line, true do
    cond do
      Regex.run( @blockquote_rgx, line ) ->
        {%Blockquote{}, behead(line, 1), false}
      matches = Regex.run( @list_item_rgx, line) ->
        [content, ws, bullet] = matches
        prefixed_with_ws(line, ws) ||
          {make_list_item(bullet), behead(line,content), false}

      matches = Regex.run( @id_open_rgx, line ) ->
        [_content, ws, id, rest ] = matches
        prefixed_with_ws(line, ws) ||
          {%IdOpen{id: id}, rest, false}
      _matches = Regex.run( @under_l1_head_rgx, line ) ->
        {%UnderHeadline{level: 1}, "", false}

      _matches = Regex.run( @under_l2_head_rgx, line ) ->
        {%UnderHeadline{level: 2}, "", false}

      matches = Regex.run( @code_fence_rgx, line ) ->
        [_line, ws] = matches
        prefixed_with_ws(line, ws) ||
          {%CodeFence{}, behead(line, 3), false}

      matches = Regex.run( @indent_rgx, line ) ->
        count = String.length(hd matches)
        {%Indent{count: count}, behead(line, count), false}

      matches = Regex.run( @headline_rgx, line ) ->
        [_line, levelstr, _ws, rest] = matches
        {%Headline{level: String.length(levelstr)}, rest, false}

      matches =  Regex.run( @ruler_rgx, line ) ->
        [_content, type] = matches
        {make_ruler_from(type), "", false}

      true ->
        scan_next_token( line, false )
    end
  end
  defp scan_next_token line, false do
    scan_token_not_at_beg( line )
    |> Tuple.append( false )
  end

  defp scan_token_not_at_beg line do
    cond do
      matches = Regex.run( @backtix_rgx, line ) ->
        [_line, backtix, rest] = matches
        {%Backtix{count: String.length(backtix)}, rest}
      # matches = Regex.run( @id_close_rgx, line ) ->
      #   [text, id, does_open] = matches
      #   {%IdDef{id: id, type:
      #      (if does_open == "", do: "close", else: "open")
      #     }, behead(line, text)}
      matches = Regex.run( @text_rgx, line ) ->
        text = hd matches
        {%Text{content: text}, behead(line, text)}
      true -> {}
    end
  end

  defp make_ruler_from type do
    case type do
      "*" -> %RulerFat{}
      "_" -> %RulerMedium{}
      "-" -> %RulerThin{}
    end
  end

  defp make_list_item bullet do
    case bullet do
      "*" -> %ListItem{type: :ul, bullet: "*"}
      "-" -> %ListItem{type: :ul, bullet: "-"}
      _   -> %ListItem{type: :ol, bullet: ""}
    end
  end

  defp prefixed_with_ws line, ws do
    if ws == "" do
      false
    else
      rest = behead( line, ws )
      {%Text{content: ws}, rest, true}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
