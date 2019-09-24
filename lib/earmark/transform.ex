defmodule Earmark.Transform do

  import Earmark.Helpers, only: [replace: 3]

  @moduledoc """
  Public Interface to functions operating on the AST
  exposed by `Earmark.as_ast`
  """

  @doc """
  **EXPERIMENTAL**
  But well tested, just expect API changes in the 1.4 branch
  Takes an ast, and optional options (I love this pun), which can be
  a map or keyword list of which the following keys will be used:

  - `smartypants:` `boolean`
  - `initial_indent:` `number`
  - `indent:` `number`

        iex(1)> Earmark.Transform.transform({"p", [], [{"em", [], "help"}, "me"]})
        "<p>\\n  <em>\\n    help\\n  </em>\\n  me\\n</p>\\n"

  Right now only transformation to HTML is supported.
  """
  def transform(ast, options \\ %{initial_indent: 0, indent: 2})
  def transform(ast, options) when is_list(options) do
    transform(ast, options|>Enum.into(%{initial_indent: 0, indent: 2}))
  end
  def transform(ast, options) when is_map(options) do
    options1 = options
      |> Map.put_new(:indent, 2)

    to_html(ast, options1)
  end
  def transform(ast, options) do
    to_html(ast, options)
  end


  defp to_html(ast, options) do
    _to_html(ast, options, Map.get(options, :initial_indent, 0)) |> IO.iodata_to_binary
  end

  defp _to_html(ast, options, level)
  defp _to_html(elements, options, level) when is_list(elements) do
    elements
    |> Enum.map(&_to_html(&1, options, level))
  end
  defp _to_html(element, options, level) when is_binary(element) do
    escape(element, options, level)
  end
  # Void tags: `area`, `br`, `hr`, `img`, and `wbr` are rendered slightly differently
  defp _to_html({"area", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp _to_html({"br", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp _to_html({"hr", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp _to_html({"img", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp _to_html({"wbr", _, _}=tag, options, level), do: void_tag(tag, options, level)
  defp _to_html({:comment, _, children}, options, level) do
    indent = make_indent(options, level)
    [ indent,
      "<!--", Enum.intersperse(children, ["\n", indent, "    "]), "-->"]
  end
  defp _to_html({tag, atts, []}, options, level) do
    [ make_indent(options, level),
      open_tag(tag, atts),
      "</",
      tag,
      ">\n" ]
  end
  defp _to_html({tag, atts, children}, options, level) do
    [ make_indent(options, level),
      open_tag(tag, atts),
      "\n",
      _to_html(children, options, level+1),
      close_tag(tag, options, level)]
  end
  
  defp close_tag(tag, options, level) do
    [make_indent(options, level), "</", tag, ">\n"]
  end

  defp escape(element, options, level)
  defp escape("", _opions, _level) do
    []
  end
  defp escape(element, options, level) do
    element1 =
        element
        |> smartypants(options)
        |> Earmark.Helpers.escape(true)
    [make_indent(options, level), element1, "\n"]
  end

  defp make_att(name_value_pair, tag)
  defp make_att({name, value}, _) do
    [" ", name, "=\"", value, "\""]
  end

  defp make_indent(%{indent: indent}, level) do
    Stream.cycle([" "])
    |> Enum.take(level*indent) 
  end

  defp open_tag(tag, atts, void? \\ false) do
    closer =
      if void?, do: " />", else: ">"
    ["<", tag, atts |> Enum.map(&make_att(&1, tag)), closer]
  end
  
  @dashes_rgx ~r{--}
  @dbl1_rgx ~r{(^|[-—/\(\[\{"”“\s])'}
  @single_rgx ~r{\'}
  @dbl2_rgx ~r{(^|[-—/\(\[\{‘\s])\"}
  @dbl3_rgx ~r{"}
  defp smartypants(text, options)
  defp smartypants(text, %{smartypants: true}) do
    text
    |> replace(@dashes_rgx, "—")
    |> replace(@dbl1_rgx, "\\1‘")
    |> replace(@single_rgx, "’")
    |> replace(@dbl2_rgx, "\\1“")
    |> replace(@dbl3_rgx, "”")
    |> String.replace("...", "…")
  end
  defp smartypants(text, _options), do: text

  defp void_tag({tag, atts, []}, options, level) do
    [ make_indent(options, level),
      open_tag(tag, atts, true),
      "\n" ]
  end
end
