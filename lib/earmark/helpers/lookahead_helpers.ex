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
  @spec read_list_lines( Line.ts, inline_code_continuation, number ) :: {boolean, Line.ts, Line.ts, number, number}
  @doc """
  Called to slurp in the lines for a list item.
  basically, we allow indents and blank lines, and
  we allow text lines only after an indent (and initially)
  We also slurp in lines that are inside a multiline inline
  code block as indicated by `pending`.
  """
  def read_list_lines( lines, {pending, pending_lnb}, initial_indent ) do
    _read_list_lines(lines, [], %{pending: pending, pending_lnb: pending_lnb, min_indent: nil, initial_indent: initial_indent})
  end

  @type read_list_info :: %{pending: maybe(String.t), pending_lnb: number, initial_indent: number, min_indent: maybe(number)}

  @spec _read_list_lines(Line.ts, Line.ts, read_list_info) :: {boolean, Line.ts, Line.ts, number}
  # List items with initial_indent + 2
  defp _read_list_lines([ line = %Line.ListItem{initial_indent: li_indent} | rest ], result,
    params=%{pending: nil, initial_indent: initial_indent, min_indent: min_indent})
  when li_indent > initial_indent + 1 do
    with {pending1, pending_lnb1} = opens_inline_code(line),
         min_indent1 = new_min_indent(min_indent, 2), do:
    _read_list_lines(rest, [ line | result ], %{params | pending: pending1, pending_lnb: pending_lnb1, min_indent: min_indent1})
  end
  # List items with same indent than last one
  defp _read_list_lines([ line = %Line.ListItem{initial_indent: li_indent} | rest ], res=[%Line.ListItem{initial_indent: old_indent} | _],
    params=%{pending: nil})
  when li_indent == old_indent do
    with {pending1, pending_lnb1} = opens_inline_code(line), do:
    _read_list_lines(rest, [ line | res ], %{params | pending: pending1, pending_lnb: pending_lnb1, min_indent: li_indent})
  end
  # text immediately after the start
  defp _read_list_lines([ line = %Line.Text{} | rest ], [], params=%{pending: nil}) do
    _read_list_lines(rest, [ line ], _opens_inline_code(line, params))
  end
  # table line immediately after the start
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], [], params=%{pending: nil}) do
    _read_list_lines(rest, [ line ], _opens_inline_code(line, params))
  end

  # text immediately after another text line
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Text{} | _], params=%{pending: nil}) do
    _read_list_lines(rest, [ line | result ], _opens_inline_code(line, params))
  end
  # table line immediately after another text line
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.Text{} | _], params=%{pending: nil}) do
    _read_list_lines(rest, [ line | result ], _opens_inline_code(line, params))
  end

  # text immediately after a table line
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.TableLine{} | _], params=%{pending: nil}) do
    _read_list_lines(rest, [ line | result ], _opens_inline_code(line, params))
  end
  # table line immediately after another table line
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.TableLine{} | _], params=%{pending: nil}) do
    _read_list_lines(rest, [ line | result ], _opens_inline_code(line, params))
  end

  # text immediately after an indent
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Indent{} | _], params=%{pending: nil}) do
    _read_list_lines(rest, [ line | result ], _opens_inline_code(line, params))
  end
  # table line immediately after an indent
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.Indent{} | _], params=%{pending: nil}) do
    _read_list_lines(rest, [ line | result ], _opens_inline_code(line, params))
  end

  # Always allow blank lines and indents, and text or table lines with at least
  # two spaces
  defp _read_list_lines([ line = %Line.Blank{} | rest ], result, params=%{pending: nil}) do
    _read_list_lines(rest, [ line | result ], params)
  end

  defp _read_list_lines([ line = %Line.Indent{level: indent_level} | rest ], result,
    params=%{pending: nil, min_indent: min_indent}) do
    with min_indent1 = new_min_indent(min_indent, indent_level * 4), do:
    _read_list_lines(rest, [ line | result ], %{params | min_indent: min_indent1})
  end

  defp _read_list_lines([ line = %Line.Text{line: <<"  ", _ :: binary>>} | rest ],
    result, params=%{pending: nil})
  do
    _read_list_lines(rest, [ line | result ], _opens_inline_code(line, params))
  end

  # no match, must be done
  defp _read_list_lines(lines, result, %{pending: nil, min_indent: min_indent}) do
    { trailing_blanks, rest } = Enum.split_while(result, &blank?/1)
    spaced = length(trailing_blanks) > 0
    { spaced, Enum.reverse(rest), lines, 0, min_indent }
  end

  # Only now we match for list lines inside an open multiline inline code block
  defp _read_list_lines([line|rest], result, params = %{pending: pending, pending_lnb: pending_lnb}) do
    with {pending1, pending_lnb1} = still_inline_code(line, {pending, pending_lnb}), do:
    _read_list_lines(rest, [%{line|inside_code: true} | result], %{params | pending: pending1, pending_lnb: pending_lnb1})
  end

  # Running into EOI insise an open multiline inline code block
  defp _read_list_lines([], result, params = %{pending_lnb: pending_lnb, min_indent: min_indent}) do
    { spaced, rest, lines, _, _ } =_read_list_lines( [], result, %{params | pending: nil} )
    { spaced, rest, lines, pending_lnb, min_indent }
  end

  defp new_min_indent(nil,            new_min_indent),                                       do: new_min_indent
  defp new_min_indent(old_min_indent, new_min_indent) when old_min_indent <= new_min_indent, do: old_min_indent
  defp new_min_indent(_,              new_min_indent),                                       do: new_min_indent

  # Convenience wrapper around `opens_inline_code` into a map
  defp _opens_inline_code( line, params ) do
    with {pending, pending_lnb} = opens_inline_code(line), do:
      %{ params | pending: pending, pending_lnb: pending_lnb }
  end
end
