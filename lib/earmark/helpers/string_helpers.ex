defmodule Earmark.Helpers.StringHelpers do
  
  @doc """
  Remove the leading part of a string
  """
  def behead(str, ignore) when is_integer(ignore) do
    String.slice(str, ignore..-1)
  end
  def behead(str, {start, length}), do: behead(str, start + length)

  def behead(str, leading_string) do
    behead(str, String.length(leading_string))
  end

end
