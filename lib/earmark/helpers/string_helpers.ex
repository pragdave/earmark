defmodule Earmark.Helpers.StringHelpers do

  @doc """
  Remove the leading part of a string
  """
  def behead(str, ignore) when is_integer(ignore) do
    String.slice(str, ignore..-1)
  end

  def behead(str, leading_string) do
    behead(str, String.length(leading_string))
  end

  @doc """
    Returns a tuple with the prefix and the beheaded string

        iex> behead_tuple("prefixpostfix", "prefix")
        {"prefix", "postfix"}
  """
  def behead_tuple(str, lead) do
    {lead, behead(str, lead)}
  end
end

# SPDX-License-Identifier: Apache-2.0
