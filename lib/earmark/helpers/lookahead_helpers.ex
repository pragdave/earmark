defmodule Earmark.Helpers.LookaheadHelpers do

  alias Earmark.Line
  import Earmark.Helpers.InlineCodeHelpers, only: [opens_inline_code: 1, still_inline_code: 2]
  import Earmark.Helpers.LineHelpers

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

  # text immediately after the start
  defp _read_list_lines([ line = %Line.Text{} | rest ], [], false) do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line ], inline_code)
  end
  # table line immediately after the start
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], [], false) do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line ], inline_code)
  end

  # text immediately after another text line
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Text{} | _], false) do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line | result ], inline_code)
  end
  # table line immediately after another text line
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.Text{} | _], false) do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line | result ], inline_code)
  end

  # text immediately after a table line
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.TableLine{} | _], false) do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line | result ], inline_code)
  end
  # table line immediately after another table line
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.TableLine{} | _], false) do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line | result ], inline_code)
  end

  # text immediately after an indent
  defp _read_list_lines([ line = %Line.Text{} | rest ], result =[ %Line.Indent{} | _], false) do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line | result ], inline_code)
  end
  # table line immediately after an indent
  defp _read_list_lines([ line = %Line.TableLine{} | rest ], result =[ %Line.Indent{} | _], false) do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line | result ], inline_code)
  end

  # Always allow blank lines and indents, and text or table lines with at least
  # two spaces
  defp _read_list_lines([ line = %Line.Blank{} | rest ], result, false) do
    _read_list_lines(rest, [ line | result ], false)
  end

  defp _read_list_lines([ line = %Line.Indent{} | rest ], result, false) do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line | result ], inline_code)
  end

  defp _read_list_lines([ line = %Line.Text{line: <<"  ", _ :: binary>>} | rest ],
  result, false)
  do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line | result ], inline_code)
  end

  defp _read_list_lines([ line = %Line.TableLine{content: text = <<"  ", _ :: binary>>} | rest ],
  result, false)
  do
    inline_code = case opens_inline_code(line) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [ line | result ], inline_code)
  end

  # no match, must be done
  defp _read_list_lines(lines, result, false) do
    { trailing_blanks, rest } = Enum.split_while(result, &blank?/1)
    spaced = length(trailing_blanks) > 0
    { spaced, Enum.reverse(rest), lines }
  end

  # Only now we match for list lines inside an open multiline inline code block
  defp _read_list_lines([line|rest], result, opening_backquotes) do
    still_inline = case still_inline_code(line.line, opening_backquotes) do
      {nil, _} -> false
      {btx, _} -> btx
    end
    _read_list_lines(rest, [%{line|inside_code: true} | result], still_inline)
  end
  # Running into EOI insise an open multiline inline code block
  defp _read_list_lines([], result, opening_backquotes) do
    IO.puts( :stderr, "Closing unclosed backquotes #{opening_backquotes} at end of input" )
    _read_list_lines( [], result, false )
  end

end
