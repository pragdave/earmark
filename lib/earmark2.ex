defmodule Earmark2 do

  import Earmark2.Scanner, only: [scan_lines: 1]

  @moduledoc """
  Will be adapted from Earmark1
  """

  @doc """
  Will be adapted from Earmark1
  """
  def as_ast(lines_or_text, options \\ %Earmark2.Options{})
  def as_ast(text, options) when is_binary(text) do
    text |> String.split(~r{\r?\n}) |> as_ast(options)
  end
  def as_ast(lines, options) do
    lines
    |> scan_lines()
    |> _sm_start([], options)
  end

  defp _sm_start(tokens, result, options \\ %Earmark2.Options{})
  defp _sm_start([], result, options), do: {:ok, Enum.reverse(result), options.messages}
  # Ignore empty line at end
  defp _sm_start([{n, []}], result, options), do: _sm_start([], result, options)
  defp _sm_start([line|rest], result, options), do: _dispatch_on_first_token(line, result, options)


  defp _dispatch_on_first_token([{lnb, []}|rest], result, options), do: _dispatch_on_empty_line(lnb, rest, result, options)

  defp _dispatch_on_empty_line(lnb, lines, result, options) do
    if options.is_complete? do
      nil
    else
      options1 = Earmark.Message.add_message(options, {:error, lnb, "unexpected empty line"})
      options2 = Earmark2.Options.next_node(options1)
      _sm_start(lines, result, options1)
    end
  end
end
