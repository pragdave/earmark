defmodule Earmark.Helpers.LookaheadHelpers do

  use Earmark.Types

  alias Earmark.Line
  import Earmark.Helpers.LineHelpers
  import Earmark.Helpers.StringHelpers

  @doc """
  Indicates if the _numbered_line_ passed in leaves an inline code block open.

  If so returns a tuple whre the first element is the opening sequence of backticks,
  and the second the linenumber of the _numbered_line_

  Otherwise `{nil, 0}` is returned 
  """
  @spec opens_inline_code(numbered_line) :: inline_code_continuation
  def opens_inline_code( %{line: line, lnb: lnb} ) do
    {:ok, tokens, _} =
    line
    |> to_char_list()
    |> :string_lexer.string()

    case has_opening_backquotes(tokens,nil) do 
    nil -> {nil, 0}
    btx -> {btx, lnb}
    end
  end

  defp has_opening_backquotes(tokens, opened_so_far)
  defp has_opening_backquotes([], opened_so_far), do: opened_so_far
  defp has_opening_backquotes([{:verbatim,_,_}|rest], opened_so_far), do: has_opening_backquotes(rest, opened_so_far)
  defp has_opening_backquotes([{:backtix,_,btx}|rest], nil), do: has_opening_backquotes(rest, to_string(btx)) 
  defp has_opening_backquotes([{:backtix,_,btx}|rest], opened_so_far) do 
  still_open = 
    if (to_string(btx) == opened_so_far) do
      nil
    else 
      opened_so_far 
    end
  has_opening_backquotes(rest, still_open)
  end

  @doc """
  returns false if and only if the line closes a pending inline code
  *without* opening a new one.
  The opening backquotes are passed in as second parameter.
  If the function does not return false it returns the (new or original)
  opening backquotes 
  """
  # (#{},{_,_}) -> {_,_}
  @spec still_inline_code(numbered_line, inline_code_continuation) :: inline_code_continuation
  def still_inline_code( %{line: line, lnb: lnb}, {pending, pending_lnb} ) do
    new_line = case ( ~r"""
    ^.*?                                 # shortest possible prefix
    (?<![\\`])#{pending}(?!`)    # unescaped ` with exactly the length of opening_backquotes
    """x |> Regex.run( line, return: :index ) ) do
      [match_index_tuple | _] ->  behead(line, match_index_tuple)
      nil                     ->  nil
    end

    case new_line do
      nil -> {pending, pending_lnb}
      _   -> opens_inline_code(%{line: new_line, lnb: lnb}) 
    end
  end

  #######################################################################################
  # read_list_lines
  #######################################################################################
  @spec read_list_lines( Line.ts, inline_code_continuation ) :: {boolean, Line.ts, Line.ts} | {boolean, Line.ts, Line.ts, {String.t, number}}
  @doc """
  Called to slurp in the lines for a list item.
  basically, we allow indents and blank lines, and
  we allow text lines only after an indent (and initially)
  We also slurp in lines that are inside a multiline inline
  code block as indicated by `pending`.
  """
  def read_list_lines( lines, pending ) do 
  _read_list_lines(lines, [], pending)
  end

  @not_pending {nil, 0}
  @spec _read_list_lines(Line.ts, Line.ts, inline_code_continuation) :: {boolean, Line.ts, Line.ts}
  # text immediately after the start
  defp _read_list_lines([ line = %Line.Text{} | rest ], [], @not_pending) do
    _read_list_lines(rest, [ line ], opens_inline_code(line))
  end
  # table line immediately after the start
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], [], @not_pending) do
    _read_list_lines(rest, [ line ], opens_inline_code(line)) 
  end

  # text immediately after another text line
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Text{} | _], @not_pending) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line)) 
  end
  # table line immediately after another text line
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.Text{} | _], @not_pending) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line)) 
  end

  # text immediately after a table line
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.TableLine{} | _], @not_pending) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line)) 
  end
  # table line immediately after another table line
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.TableLine{} | _], @not_pending) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line)) 
  end

  # text immediately after an indent
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Indent{} | _], @not_pending) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line)) 
  end
  # table line immediately after an indent
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.Indent{} | _], @not_pending) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line)) 
  end

  # Always allow blank lines and indents, and text or table lines with at least
  # two spaces
  defp _read_list_lines([ line = %Line.Blank{} | rest ], result, @not_pending) do
    _read_list_lines(rest, [ line | result ], @not_pending)
  end

  defp _read_list_lines([ line = %Line.Indent{} | rest ], result, @not_pending) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line)) 
  end

  defp _read_list_lines([ line = %Line.Text{line: <<"  ", _ :: binary>>} | rest ],
  result, @not_pending)
  do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line)) 
  end

  defp _read_list_lines([ line = %Line.TableLine{content: <<"  ", _ :: binary>>} | rest ],
  result, @not_pending)
  do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line)) 
  end

  # no match, must be done
  defp _read_list_lines(lines, result, @not_pending) do
    { trailing_blanks, rest } = Enum.split_while(result, &blank?/1)
    spaced = length(trailing_blanks) > 0
    { spaced, Enum.reverse(rest), lines }
  end

  # Only now we match for list lines inside an open multiline inline code block
  defp _read_list_lines([line|rest], result, pending) do
    _read_list_lines(rest, [%{line|inside_code: true} | result], still_inline_code(line, pending))
  end
  # Running into EOI insise an open multiline inline code block
  defp _read_list_lines([], result, pending) do
    { spaced, rest, lines } =_read_list_lines( [], result, @not_pending )
    { spaced, rest, lines, pending }
  end

end
