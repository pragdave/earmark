defmodule Earmark.Helpers.HtmlHelpers do

  import Earmark.Helpers.AttrParser
  
  @simple_tag ~r{^<(.*?)\s*>}

  @doc false

  def augment_tag_with_ial(tag, ial, lnb) do 
    case Regex.run( @simple_tag, tag) do 
      nil -> nil
      _   -> add_attrs(tag, ial, [], lnb)
    end
    
  end


  ##############################################
  # add attributes to the outer tag in a block #
  ##############################################

  @doc false
  def add_attrs!(text, attrs_as_string_or_map, default_attrs, lnb ) do
    with {text, _errors} <- add_attrs(text, attrs_as_string_or_map, default_attrs, lnb), do: text
  end

  defp add_attrs(text, attrs_as_string_or_map, default_attrs, lnb )

  defp add_attrs(text, nil, [], _lnb), do: text

  defp add_attrs(text, nil, default, lnb), do: add_attrs(text, %{}, default, lnb)

  defp add_attrs(text, attrs, default, lnb) when is_binary(attrs) do
    attrs = parse_attrs( attrs, lnb )
    add_attrs(text, attrs, default, lnb)
  end

  defp add_attrs(text, attrs, default, _lnb) do
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

end
