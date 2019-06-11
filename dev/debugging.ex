defmodule Dev.Debugging do


  def print_html(markdown) do
    markdown
    |> Earmark.as_html!
    |> IO.puts
  end

  def parse(markdown) do
    Earmark.Parser.parse_markdown(markdown)
    |> remove_context()
  end

  def nth(something, n) do
    {something, _nth(something, n)}
  end

  defp _nth(something, n)
  defp _nth(tuple, n) when is_tuple(tuple) do
    _nth(Tuple.to_list(tuple), n)
  end
  defp _nth(list, n) when is_list(list) do
    Enum.at(list, n)
  end

  def inspect_only({original, collection}, elements) do
    {original,
      collection
      |> Enum.map(only(elements))
      |> IO.inspect
    }
  end
  def inspect_only(collection, elements) do
    collection
      |> Enum.map(only(elements))
      |> IO.inspect
    collection
  end

  def ret({original, _}), do: original

  defp only(elements) do
    fn a_map ->
      Map.take(a_map, [:__struct__ | elements])
    end
  end

  defp remove_context({nodes, _context}), do: nodes

end
