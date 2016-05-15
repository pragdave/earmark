defmodule Earmark.Helpers.LookaheadHelpers do

  use Earmark.Types

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
  @spec read_list_lines( Line.ts, inline_code_continuation )::{any, Line.ts, Line.ts}
  def read_list_lines( lines, pending ) do 
    _read_list_lines(lines, [], pending)
  end

  @not_pending {nil, 0}
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

  defp _read_list_lines([ line = %Line.TableLine{content: text = <<"  ", _ :: binary>>} | rest ],
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
