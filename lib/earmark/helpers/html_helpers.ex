defmodule Earmark.Helpers.HtmlHelpers do

  import Earmark.Helpers.AttrParser
  alias Earmark.Message
  
  @simple_tag ~r{^<(.*?)\s*>}

  @doc false

  def augment_tag_with_ial(tag, ial) do 
    case Regex.run( @simple_tag, tag) do 
      nil -> nil
      [_, inner] -> add_attrs(tag, ial)
    end
    
  end


  ##############################################
  # add attributes to the outer tag in a block #
  ##############################################

  @doc false
  def add_attrs!(text, attrs_as_string_or_map, default_attrs \\ []) do
    with {text, _errors} <- add_attrs(text, attrs_as_string_or_map, default_attrs), do: text
  end

  defp add_attrs(text, attrs_as_string_or_map, default_attrs \\ [])

  defp add_attrs(text, nil, []), do: text

  defp add_attrs(text, nil, default), do: add_attrs(text, %{}, default)

  defp add_attrs(text, attrs, default) when is_binary(attrs) do
    with {attrs, errors} <- parse_attrs( attrs ) do
      IO.inspect errors
      {add_attrs(text, attrs, default), format(errors)}
    end
  end
  defp add_attrs(text, attrs, default) do
    default
    |> Enum.into(attrs)
    |> attrs_to_string()
    |> add_to(text)
  end

  defp attrs_to_string(attrs) do
    (for { name, value } <- attrs, do: ~s/#{name}="#{Enum.join(value, " ")}"/)
                                                  |> Enum.join(" ")
  end

  defp add_to(attrs, text) do
    attrs = if attrs == "", do: "", else: " #{attrs}"
    String.replace(text, ~r{\s?/?>}, "#{attrs}\\0", global: false)
  end

  defp format(errors, line \\ 0) do 
    errors
    |> Enum.map(fn error ->
      Message.new_warning(line, error)
    end)
  end
end
