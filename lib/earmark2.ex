defmodule Earmark2 do

  import Earmark2.Scanner, only: [scan: 1]

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
    |> Enum.map(&scan/1)
    |> Enum.zip(Stream.iterate(1, &(1+&1)))
    |> Enum.flat_map(&with_lnb_and_eol(&1, []))
  end


  defp with_lnb_and_eol(tokens, rest)
  defp with_lnb_and_eol({[], lnb}, rest), do:
    [{:eol, "\n", lnb} | rest] |> Enum.reverse 
  defp with_lnb_and_eol({[{token, content}|tail], lnb}, result), do:
    with_lnb_and_eol({tail, lnb}, [{token, content, lnb}|result])
end
