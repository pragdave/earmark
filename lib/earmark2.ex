defmodule Earmark2 do

  import Earmark2.Scanner, only: [scan_line: 1]

  @moduledoc """
  Will be adapted from Earmark1
  """

  @doc """
  Will be adapted from Earmark1
  """
  def as_ast(lines_or_text, options \\ %Earmark.Options{})
  def as_ast(text, options) when is_binary(text) do
    text |> String.split(~r{\r?\n}) |> as_ast(options)
  end
  def as_ast(lines, options) do
    tokenized_lines = lines |> Stream.zip(Stream.iterate(1, &(&1+1))) |> Enum.map(&scan_line/1)
    _sm_start(tokenized_lines, [], options)
  end


  defp _sm_start(lines, result, options \\ %Earmark.Options{})
  defp _sm_start([], result, options), do: {:ok, Enum.reverse(result), options.messages}
  # Ignore empty line at end
  defp _sm_start([{n, []}], result, options), do: _sm_start([], result, options)


end
