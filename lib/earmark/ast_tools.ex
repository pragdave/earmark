defmodule Earmark.AstTools do
  @moduledoc """
  Tools for AST manipulation
  """

  @doc """

  A helper to merge attributes in their cannonical representation


      iex(0)> merge_atts([{"href", "url"}], target: "_blank")
      [{"href", "url"}, {"target", "_blank"}]

      iex(1)> merge_atts([{"href", "url"}, {"target", "nonsense"}], %{"target" => "_blank"})
      [{"href", "url"}, {"target", "_blank nonsense"}]

      iex(2)>  merge_atts([{"href", "url"}, {"target", "nonsense"}, {"alt", "nowhere"}],
      ...(2)>              [{"target", "_blank"}, title: "where?"])
      [{"alt", "nowhere"}, {"href", "url"}, {"target", "_blank nonsense"}, {"title", "where?"}]
  """
  def merge_atts(attrs, new)
  def merge_atts(attrs, new) do
    attrs
    |> Enum.into(%{})
    |> Map.merge(_stringyfy(new), &_combine_atts/3)
    |> Enum.into([])
  end

  @doc """
  A convenience function that extracts the original attributes to be merged with new attributes
  and puts the result into the node again

      iex(3)> merge_atts_in_node({"img", [{"src", "there"}, {"alt", "there"}], [], %{some: "meta"}}, alt: "here")
      {"img", [{"alt", "here there"}, {"src", "there"}], [], %{some: "meta"}}

  """
  def merge_atts_in_node({tag, atts, content, meta}, new_atts) do
    {tag, merge_atts(atts, new_atts), content, meta}
  end

  defp _combine_atts(_key, original, new), do: "#{new} #{original}"

  defp _stringyfy(mappy)
  defp _stringyfy(map) when is_map(map) do
    map |> Enum.into([]) |> _stringyfy()
  end
  defp _stringyfy(list) when is_list(list) do
    list |> Enum.map(fn {k, v} -> {to_string(k), v} end) |> Enum.into(%{})
  end

end
#  SPDX-License-Identifier: Apache-2.0
