defmodule Earmark.Helpers.LookaheadHelpers do

  use Earmark.Types

  alias Earmark.Line
  import Earmark.Helpers.LineHelpers
  import Earmark.Helpers.LeexHelpers

  @doc """
  Indicates if the _numbered_line_ passed in leaves an inline code block open.

  If so returns a tuple whre the first element is the opening sequence of backticks,
  and the second the linenumber of the _numbered_line_

  Otherwise `{nil, 0}` is returned
  """
  @spec opens_inline_code(numbered_line) :: inline_code_continuation
  def opens_inline_code( %{line: line, lnb: lnb} ) do
    case tokenize(line, with: :string_lexer) |> has_still_opening_backtix(nil) do
      nil      -> {nil, 0}
      {_, btx} -> {btx, lnb}
    end
  end

  @doc """
  returns false if and only if the line closes a pending inline code
  *without* opening a new one.
  The opening backtix are passed in as second parameter.
  If the function does not return false it returns the (new or original)
  opening backtix
  """
  # (#{},{_,_}) -> {_,_}
  @spec still_inline_code(numbered_line, inline_code_continuation) :: inline_code_continuation
  def still_inline_code( %{line: line, lnb: lnb}, old = {pending, _pending_lnb} ) do
    case tokenize(line, with: :string_lexer) |> has_still_opening_backtix({:old, pending}) do
      nil -> {nil, 0}
      {:new, btx} -> {btx, lnb}
      {:old, _  } -> old
    end
  end

  # A tokenized line {:verabtim, text} | {:backtix, ['``+]} is analyzed for
  # if it is closed (-> nil), not closed (-> {:old, btx}) or reopened (-> {:new, btx})
  # concerning backtix
  defp has_still_opening_backtix(tokens, opened_so_far)

  defp has_still_opening_backtix([], opened_so_far), do: opened_so_far
  defp has_still_opening_backtix([{:verbatim,_}|rest], opened_so_far), do: has_still_opening_backtix(rest, opened_so_far)
  defp has_still_opening_backtix([{:backtix,btx}|rest], nil), do: has_still_opening_backtix(rest, {:new, btx})
  defp has_still_opening_backtix([{:backtix,btx}|rest], opened_so_far={_, pending}) do
    if btx == pending do
      has_still_opening_backtix(rest, nil)
    else
      has_still_opening_backtix(rest, opened_so_far)
    end
  end

  #######################################################################################
  # read_list_lines
  #######################################################################################
  @spec read_list_lines( Line.ts, inline_code_continuation, number ) :: {boolean, Line.ts, Line.ts, number, maybe(number)}
  @doc """
  Called to slurp in the lines for a list item.
  basically, we allow indents and blank lines, and
  we allow text lines only after an indent (and initially)
  We also slurp in lines that are inside a multiline inline
  code block as indicated by `pending`.
  """
  def read_list_lines( lines, pending, initial_indent ) do
    _read_list_lines(lines, [], pending, nil, initial_indent)
  end

  @not_pending {nil, 0}
  @spec _read_list_lines(Line.ts, Line.ts, inline_code_continuation, maybe(number), number) :: {boolean, Line.ts, Line.ts, maybe(number)}
  # List items with initial_indent + 2
  defp _read_list_lines([ line = %Line.ListItem{initial_indent: li_indent} | rest ], [], @not_pending, minindent, initial_indent)
  when li_indent == initial_indent + 2 do
    _read_list_lines(rest, [ line ], opens_inline_code(line), new_minindent(minindent, 2), initial_indent)
  end
  # text immediately after the start
  defp _read_list_lines([ line = %Line.Text{} | rest ], [], @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line ], opens_inline_code(line), minindent, initial_indent)
  end
  # table line immediately after the start
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], [], @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line ], opens_inline_code(line), minindent, initial_indent)
  end

  # text immediately after another text line
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Text{} | _], @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line), minindent, initial_indent)
  end
  # table line immediately after another text line
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.Text{} | _], @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line), minindent, initial_indent)
  end

  # text immediately after a table line
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.TableLine{} | _], @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line), minindent, initial_indent)
  end
  # table line immediately after another table line
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.TableLine{} | _], @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line), minindent, initial_indent)
  end

  # text immediately after an indent
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Indent{} | _], @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line), minindent, initial_indent)
  end
  # table line immediately after an indent
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.Indent{} | _], @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line), minindent, initial_indent)
  end

  # Always allow blank lines and indents, and text or table lines with at least
  # two spaces
  defp _read_list_lines([ line = %Line.Blank{} | rest ], result, @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line | result ], @not_pending, minindent, initial_indent)
  end

  defp _read_list_lines([ line = %Line.Indent{level: indent_level} | rest ], result, @not_pending, minindent, initial_indent) do
    _read_list_lines(rest, [ line | result ], @not_pending, new_minindent(minindent, indent_level * 4), initial_indent)
  end

  defp _read_list_lines([ line = %Line.Text{line: <<"  ", _ :: binary>>} | rest ],
  result, @not_pending, minindent, initial_indent)
  do
    _read_list_lines(rest, [ line | result ], opens_inline_code(line), minindent, initial_indent)
  end

  # no match, must be done
  defp _read_list_lines(lines, result, @not_pending, minindent, _initial_indent) do
    { trailing_blanks, rest } = Enum.split_while(result, &blank?/1)
    spaced = length(trailing_blanks) > 0
    { spaced, Enum.reverse(rest), lines, 0, minindent }
  end

  # Only now we match for list lines inside an open multiline inline code block
  defp _read_list_lines([line|rest], result, pending, minindent, initial_indent) do
    _read_list_lines(rest, [%{line|inside_code: true} | result], still_inline_code(line, pending), minindent, initial_indent)
  end

  # Running into EOI insise an open multiline inline code block
  defp _read_list_lines([], result, {_, pending_lnb}, minindent, initial_indent) do
    { spaced, rest, lines, _, _ } =_read_list_lines( [], result, @not_pending, minindent, initial_indent)
    { spaced, rest, lines, pending_lnb, minindent }
  end

  defp new_minindent(nil,           new_minindent),                                     do: new_minindent
  defp new_minindent(old_minindent, new_minindent) when old_minindent <= new_minindent, do: old_minindent
  defp new_minindent(_,             new_minindent),                                     do: new_minindent
end
