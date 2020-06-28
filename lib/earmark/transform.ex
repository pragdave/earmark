defmodule Earmark.Transform do

  import Earmark.Helpers, only: [replace: 3]

  @compact_tags ~w[a code em strong]

  # https://www.w3.org/TR/2011/WD-html-markup-20110113/syntax.html#void-element
  @void_elements ~W(area base br col command embed hr img input keygen link meta param source track wbr)

  @moduledoc """
  Public Interface to functions operating on the AST
  exposed by `Earmark.as_ast`
  """

  @doc """
    Needs update for 1.4.6
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


  defp to_html(ast, options) do
    _to_html(ast, options, Map.get(options, :initial_indent, 0))|> IO.iodata_to_binary
  end

  defp _to_html(ast, options, level, verbatim \\ false)
  defp _to_html({:comment, _, content, _}, _options, _level, _verbatim) do
    "<!--#{content |> Enum.intersperse("\n")}-->"
  end
  defp _to_html({tag, atts, children, _}, options, level, verbatim) when tag in @compact_tags do
    [open_tag(tag, atts),
       children
       |> Enum.map(&_to_html(&1, Map.put(options, :compact, true), level, verbatim)),
       "</#{tag}>"]
  end
  defp _to_html({tag, atts, _, _}, options, level, _verbatim) when tag in @void_elements do
    [ make_indent(options, level), open_tag(tag, atts), "\n" ]
  end
  defp _to_html(elements, options, level, verbatim) when is_list(elements) do
    elements
    |> Enum.map(&_to_html(&1, options, level, verbatim))
  end
  defp _to_html(element, options, level, false) when is_binary(element) do
    escape(element, options, level)
  end
  defp _to_html(element, options, level, true) when is_binary(element) do
    [make_indent(options, level), element]
  end
  defp _to_html({"pre", atts, children, meta}, options, level, _verbatim) do
    verbatim = meta |> Map.get(:verbatim, false)
    [ make_indent(options, level),
      open_tag("pre", atts),
      _to_html(children, Map.put(options, :smartypants, false), level, verbatim),
      "</pre>\n"]
  end
  defp _to_html({tag, atts, children, meta}, options, level, _verbatim) do
    verbatim = meta |> Map.get(:verbatim, false)
    [ make_indent(options, level),
      open_tag(tag, atts),
      "\n",
      _to_html(children, options, level+1, verbatim),
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
    compact = Map.get(options, :compact, false)
    element1 =
        element
        |> smartypants(options)
        |> Earmark.Helpers.escape(true)
    if compact do
      element1
    else
      [make_indent(options, level), element1, "\n"]
    end
  end

  defp make_att(name_value_pair, tag)
  defp make_att({name, value}, _) do
    [" ", name, "=\"", value, "\""]
  end

  defp make_indent(%{indent: indent}, level) do
    Stream.cycle([" "])
    |> Enum.take(level*indent) 
  end

  defp open_tag(tag, atts)
  defp open_tag(tag, atts) when tag in @void_elements do
    ["<", "#{tag}", Enum.map(atts, &make_att(&1, tag)), " />"]
  end
  defp open_tag(tag, atts) do
    ["<", "#{tag}", Enum.map(atts, &make_att(&1, tag)), ">"]
  end

  @em_dash_rgx ~r{---}
  @en_dash_rgx ~r{--}
  @dbl1_rgx ~r{(^|[-–—/\(\[\{"”“\s])'}
  @single_rgx ~r{\'}
  @dbl2_rgx ~r{(^|[-–—/\(\[\{‘\s])\"}
  @dbl3_rgx ~r{"}
  defp smartypants(text, options)
  defp smartypants(text, %{smartypants: true}) do
    text
    |> replace(@em_dash_rgx, "—")
    |> replace(@en_dash_rgx, "–")
    |> replace(@dbl1_rgx, "\\1‘")
    |> replace(@single_rgx, "’")
    |> replace(@dbl2_rgx, "\\1“")
    |> replace(@dbl3_rgx, "”")
    |> String.replace("...", "…")
  end
  defp smartypants(text, _options), do: text

end
