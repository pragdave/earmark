defmodule Earmark.Helpers.AstHelpers do

  @moduledoc false

  import Earmark.Ast.Emitter
  import Earmark.Helpers
  import Earmark.Helpers.AttrParser

  alias Earmark.Block
  
  @doc false
  def augment_tag_with_ial(tags, ial)
  def augment_tag_with_ial([{t, a, c}|tags], atts) do
    [{t, merge_attrs(a, atts), c}|tags]
  end
  def augment_tag_with_ial([], _atts) do
    [] 
  end

  @doc false
  def code_classes(language, prefix) do
    classes =
      ["" | String.split(prefix || "")]
      |> Enum.map(fn pfx -> "#{pfx}#{language}" end)
      {"class", classes |> Enum.join(" ")}
  end

  @doc false
  def codespan(text) do 
    emit("code", text, class: "inline")
  end

  @doc false
  def render_footnote_link(ref, backref, number) do
    emit("a", to_string(number), href: "##{ref}", id: backref, class: "footnote", title: "see footnote")
  end

  @doc false
  def render_code(%Block.Code{lines: lines}) do
    lines |> Enum.join("\n")
  end

  @remove_escapes ~r{ \\ (?! \\ ) }x
  @doc false
  def render_image(text, href, title) do
    alt = text |> escape() |> String.replace(@remove_escapes, "")

    if title do
      emit("img", [], src: href, alt: alt, title: title)
    else
      emit("img", [], src: href, alt: alt)
    end
  end

  @doc false
  def render_link(url, text) do
    url =
      try do
        url
        |> URI.decode
        |> URI.encode
      rescue
        _ -> url
      end

    text =
      try do
        URI.decode(text)
      rescue
        _ -> text
      end

    emit("a", text, href: url)
  end


  ##############################################
  # add attributes to the outer tag in a block #
  ##############################################

  @doc false
  def merge_attrs(maybe_atts, new_atts)
  def merge_attrs(nil, new_atts), do: new_atts
  def merge_attrs(atts, new) do
    atts
    |> Map.merge(new, &_value_merger/3)
  end

  @doc false
  def add_attrs(context, text, attrs_as_string_or_map, default_attrs, lnb)
  def add_attrs(context, text, nil, [], _lnb), do: {context, text}
  def add_attrs(context, text, nil, default, lnb), do: add_attrs(context, text, %{}, default, lnb)
  def add_attrs(context, text, attrs, default, lnb) when is_binary(attrs) do
    {context1, attrs} = parse_attrs( context, attrs, lnb )
    add_attrs(context1, text, attrs, default, lnb)
  end
  def add_attrs(_context, _text, attrs, default, _lnb) do
      default
      |> Map.new()
      |> Map.merge(attrs, fn _k, v1, v2 -> v1 ++ v2 end)
  end

  defp _value_merger(key, val1, val2)
  defp _value_merger(_, val1, val2) when is_list(val1) and is_list(val2) do
    val1 ++ val2
  end
  defp _value_merger(_, val1, val2) when is_list(val1) do
    val1 ++ [val2]
  end
  defp _value_merger(_, val1, val2) do
    [val1, val2]
  end


end
# SPDX-License-Identifier: Apache-2.0
