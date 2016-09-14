defmodule Earmark.Helpers.InlineHelpers do

  use Earmark.Types
  import Earmark.Helpers.StringHelpers, only: [behead_tuple: 2]
  import Earmark.Helpers.LeexHelpers

  @spec parse_link( String.t ) :: maybe(list(String.t))
  def parse_link(src)

  def parse_link(<< "[", _ :: binary >> = src) do
    case parse_rec(src, "[", "]") do
      nil -> nil
      result -> behead_tuple(src, result)
    end
  end

  def parse_link(_src), do: nil

  @spec parse_title_or_alt( String.t ) :: maybe({String.t, String.t})
  defp parse_title_or_alt(src) do
    case parse_rec(src, "[", "]") do
      nil -> nil
      result -> behead_tuple(src, result)
    end
  end

  defp parse_rec _src, _open, _close do
  end
  

end
