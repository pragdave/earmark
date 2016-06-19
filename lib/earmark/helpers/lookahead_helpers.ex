defmodule Earmark.Helpers.LookaheadHelpers do

  use Earmark.Types

  alias Earmark.Line
  import Earmark.Helpers.LineHelpers
  import Earmark.Helpers.StringHelpers

  @doc """
  Returns maybe string, where some string is an opening and not closed sequence of backticks.
  `nil` is returned if no inline code is left open.
  """
  @spec inline_code_opened?(String.t) :: maybe(String.t)
  def inline_code_opened?( line ) do
    line
    |> behead_unopening_text
    |> has_opening_backquotes
  end

  @inline_pairs ~r'''
  ^(?:
  (?:[^`]|\\`)*      # shortes possible prefix, not consuming unescaped `
  (?<!\\)(`++)       # unescaped `, assuring longest match of `
  .+?                # shortest match before...
  (?<![\\`])\1(?!`)  # closing same length ` sequence
  )+
  '''x
  @spec behead_unopening_text(String.t()) :: String.t()
  # All pairs of sequences of backquotes and text in front and in between
  # are removed from line.
  defp behead_unopening_text( line ) do 
  case Regex.run( @inline_pairs, line, return: :index ) do
    [match_index_tuple | _rest] -> behead( line, match_index_tuple )
    _no_match                   -> line
  end 
  end

  @first_opening_backquotes ~r'''
  ^(?:[^`]|\\`)*      # shortes possible prefix, not consuming unescaped `
  (?<!\\)(`++)        # unescaped `, assuring longest match of `
  '''x
  @spec has_opening_backquotes(String.t()) :: maybe( String.t )
  def has_opening_backquotes line do
    case Regex.run( @first_opening_backquotes, line ) do 
    [_total, opening_backquotes | _rest] -> opening_backquotes
    _no_match                            -> nil
    end
  end

  @doc """
  Tests if `line` leaves an opened inline code block open.
  `pending_btx` indicates the opening backticks sequence of the pending inline block.
  Returns some string when the pending or a new inline code block remains open, where
  the string indicats the (new) pending backticks sequence.
  Nil indicates that no inline code block is left open by `line`
  """
  @spec inline_code_continues?( String.t, String.t ) :: maybe(String.t)
  def inline_code_continues?( line, pending_btx ) do
    new_line = behead_pending_inline_code( line, pending_btx )

    case new_line do
      nil -> pending_btx
      _   -> inline_code_opened?(new_line) 
    end
  end

  defp behead_pending_inline_code( line, pending_btx ) do 
    case ( ~r"""
    ^.*?                             # shortest possible prefix
    (?<![\\`])#{pending_btx}(?!`)    # unescaped ` with exactly the length of opening_backquotes
    """x |> Regex.run( line, return: :index ) ) do
      [match_index_tuple | _] ->  behead(line, match_index_tuple)
      nil                     ->  nil
    end
  end
  #######################################################################################
  # read_list_lines
  #######################################################################################
  @spec read_list_lines( Line.ts, maybe(String) ) :: {boolean, Line.ts, Line.ts} | {boolean, Line.ts, Line.ts, {String.t, number}}
  @doc """
  Called to slurp in the lines for a list item.
  basically, we allow indents and blank lines, and
  we allow text lines only after an indent (and initially)
  We also slurp in lines that are inside a multiline inline
  code block as indicated by `pending`.
  """
  def read_list_lines( lines, pending ) do 
    case result = _read_list_lines(lines, [], pending ) do
      {spaced, list_lines, rest, _} -> {spaced, list_lines, rest}
      _                             -> result
    end
  end

  @spec _read_list_lines(Line.ts, Line.ts, maybe(String.t)) :: {boolean, Line.ts, Line.ts}
  # text immediately after the start
  defp _read_list_lines([ line = %Line.Text{line: line_text} | rest ], [], nil) do
    _read_list_lines(rest, [ line ], inline_code_opened?(line_text))
  end
  # table line immediately after the start
  defp _read_list_lines([ line = %Line.TableLine{line: line_text} | rest ], [], nil) do
    _read_list_lines(rest, [ line ], inline_code_opened?(line_text)) 
  end

  # text immediately after another text line
  defp _read_list_lines([ line = %Line.Text{line: line_text} | rest ], result =[ %Line.Text{} | _], nil) do
    _read_list_lines(rest, [ line | result ], inline_code_opened?(line_text)) 
  end
  # table line immediately after another text line
  defp _read_list_lines([ line = %Line.TableLine{line: line_text} | rest ], result =[ %Line.Text{} | _], nil) do
    _read_list_lines(rest, [ line | result ], inline_code_opened?(line_text)) 
  end

  # text immediately after a table line
  defp _read_list_lines([ line = %Line.Text{line: line_text} | rest ], result =[ %Line.TableLine{} | _], nil) do
    _read_list_lines(rest, [ line | result ], inline_code_opened?(line_text)) 
  end
  # table line immediately after another table line
  defp _read_list_lines([ line = %Line.TableLine{line: line_text} | rest ], result =[ %Line.TableLine{} | _], nil) do
    _read_list_lines(rest, [ line | result ], inline_code_opened?(line_text)) 
  end

  # text immediately after an indent
  defp _read_list_lines([ line = %Line.Text{line: line_text} | rest ], result =[ %Line.Indent{} | _], nil) do
    _read_list_lines(rest, [ line | result ], inline_code_opened?(line_text)) 
  end
  # table line immediately after an indent
  defp _read_list_lines([ line = %Line.TableLine{line: line_text} | rest ], result =[ %Line.Indent{} | _], nil) do
    _read_list_lines(rest, [ line | result ], inline_code_opened?(line_text)) 
  end

  # Always allow blank lines and indents, and text or table lines with at least
  # two spaces
  defp _read_list_lines([ line = %Line.Blank{} | rest ], result, nil) do
    _read_list_lines(rest, [ line | result ], nil)
  end

  defp _read_list_lines([ line = %Line.Indent{line: line_text} | rest ], result, nil) do
    _read_list_lines(rest, [ line | result ], inline_code_opened?(line_text)) 
  end

  defp _read_list_lines([ line = %Line.Text{line: (line_text = <<"  ", _ :: binary>>)} | rest ],
  result, nil)
  do
    _read_list_lines(rest, [ line | result ], inline_code_opened?(line_text)) 
  end

  defp _read_list_lines([ line = %Line.TableLine{content: (line_text = <<"  ", _ :: binary>>)} | rest ],
  result, nil)
  do
    _read_list_lines(rest, [ line | result ], inline_code_opened?(line_text)) 
  end

  # no match, must be done
  defp _read_list_lines(lines, result, nil) do
    { trailing_blanks, rest } = Enum.split_while(result, &blank?/1)
    spaced = length(trailing_blanks) > 0
    { spaced, Enum.reverse(rest), lines }
  end

  # Only now we match for list lines inside an open multiline inline code block
  defp _read_list_lines([line=%{line: line_text}|rest], result, pending) do
    _read_list_lines(rest, [%{line|inside_code: true} | result], inline_code_continues?(line_text, pending))
  end
  # Running into EOI insise an open multiline inline code block
  defp _read_list_lines([], result, pending) do
    { spaced, rest, lines } =_read_list_lines( [], result, nil )
    { spaced, rest, lines, pending }
  end

end
