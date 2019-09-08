defmodule Earmark.Transform do

  import Earmark.Helpers, only: [escape: 1]

  @moduledoc """
  Public Interface to functions operating on the AST
  exposed by `Earmark.as_ast`
  """

  @doc """
  Takes an ast, and optional options (I love this pun), which can be
  a map or keyword list of which the following keys will be used:

  - `smarty_pants:` `boolean`
  - `initial_indent:` `number`
  - `indent:` `number`


  Right now only transformation to HTML is supported.
  """
  def transform(ast, options \\ %{initial_indent: 0, indent: 2})
  def transform(ast, options) when is_list(options) do
    transform(ast, options|>Enum.into(%{initial_indent: 0, indent: 2}))
  end
  def transform(ast, options) do
    to_html(ast, options, 0) |> IO.iodata_to_binary
  end


  defp to_html(ast, options, level)
  defp to_html(elements, options, level) when is_list(elements) do
    elements
    |> Enum.map(&to_html(&1, options, level))
  end
  defp to_html(element, options, level) when is_binary(element) do
    escape(element, options, level)
  end
  # Void tags: `area`, `br`, `hr`, `img`, and `wbr` are rendered slightly differently
  defp to_html({"area", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp to_html({"br", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp to_html({"hr", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp to_html({"img", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp to_html({"wbr", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp to_html({tag, atts, children}, options, level) do
    [ make_indent(options, level),
      open_tag(tag, atts),
      "\n",
      to_html(children, options, level+1),
      close_tag(tag, options, level)]
  end
  
  defp close_tag(tag, options, level) do
    [make_indent(options, level), "</", tag, ">\n"]
  end

  # TODO: Implement HTML escapes and option smartypants
  defp escape(element, options, level) do
    [make_indent(options, level), element, "\n"]
  end

  defp make_att(name_value_pair, tag)
  defp make_att({"src", value}, "img"), do: _make_encoded_attr("src", value)
  defp make_att({"href", value}, "a"), do: _make_encoded_attr("href", value)
  defp make_att({name, value}, _) do
    [" ", name, "=\"", value, "\""]
  end
  defp _make_encoded_attr(name, value) do
    [" ", name, "=\"", escape(value), "\""]
  end

  defp make_indent(%{initial_indent: initial, indent: indent}, level) do
    Stream.cycle([" "])
    |> Enum.take((initial+level)*indent) 
  end

  defp open_tag(tag, atts, void? \\ false) do
    closer =
      if void?, do: " />", else: ">"
    ["<", tag, atts |> Enum.map(&make_att(&1, tag)), closer]
  end
  
  defp void_tag({tag, atts, []}, options, level) do
    [ make_indent(options, level),
      open_tag(tag, atts, true),
      "\n" ]
  end
end
