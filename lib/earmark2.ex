defmodule Earmark2 do

  import Earmark2.Scanner, only: [scan_line: 1]

  @moduledoc """
  Will be adapted from Earmark1
  """

  @doc """
  Will be adapted from Earmark1
  """
  def as_html(lines, options \\ %Earmark.Options{})
  def as_html(lines, options) when is_binary(lines) do
    lines
    |> String.split(~r{\r\n?|\n})
    |> as_html(options)
  end
  def as_html(lines, _options) do
    lines
    |> Enum.zip(Stream.iterate(1, &(1+&1)))
    |> Enum.flat_map(&with_lnb_and_eol(&1, []))
  end

  def old_blocks( x ) when is_binary(x) do
    x |> String.split(~r{\r?\n}) |> old_blocks()
  end
  def old_blocks(x) do
    with {block, lnx, _} <-x |> Earmark.Parser.parse(%Earmark.Options{}, false) do
      {block, lnx}
    end
  end

  def old_lines( x ) when is_binary(x) do
    x |> String.split(~r{\r?\n}) |> old_lines()
  end
  def old_lines( x ) do
    x |> Earmark.Line.scan_lines(%Earmark.Options{}, false)
  end

  def x, do: "* hello\n   line 1\n   - world\n     line 2\n   - again\n"                 
  def y, do: "* hello\n   line 1\n   - world\nline 2\n   - again\n"        
  


  defp with_lnb_and_eol(tokens, rest)
  defp with_lnb_and_eol({[], lnb}, rest), do:
    [{:eol, "\n", lnb} | rest] |> Enum.reverse 
  defp with_lnb_and_eol({[{token, content}|tail], lnb}, result), do:
    with_lnb_and_eol({tail, lnb}, [{token, content, lnb}|result])
end
