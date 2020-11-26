defmodule Earmark.Transform do

  import Earmark.Helpers, only: [replace: 3]

  @compact_tags ~w[a code em strong del]

  # https://www.w3.org/TR/2011/WD-html-markup-20110113/syntax.html#void-element
  @void_elements ~W(area base br col command embed hr img input keygen link meta param source track wbr)

  @moduledoc """
  Public Interface to functions operating on the AST
  exposed by `Earmark.as_ast`
  """

  @doc """
    Needs update for 1.4.7
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


  defp maybe_add_newline(%{compact_output: true}), do: []
  defp maybe_add_newline(_), do: ?\n

  defp to_html(ast, options) do
    _to_html(ast, options, Map.get(options, :initial_indent, 0))|> IO.iodata_to_binary
  end

  defp _to_html(ast, options, level, verbatim \\ false)
  defp _to_html({:comment, _, content, _}, options, _level, _verbatim) do
    ["<!--", Enum.intersperse(content, ?\n), "-->", maybe_add_newline(options)]
  end
  defp _to_html({"code", atts, children, meta}, options, level, _verbatim) do
    verbatim = meta |> Map.get(:verbatim, false)
    [ open_tag("code", atts),
      _to_html(children, Map.put(options, :smartypants, false), level, verbatim),
      "</code>"]
  end
  defp _to_html({tag, atts, children, _}, options, level, verbatim) when tag in @compact_tags do
    [open_tag(tag, atts),
       children
       |> Enum.map(&_to_html(&1, options, level, verbatim)),
       "</", tag, ?>]
  end
  defp _to_html({tag, atts, _, _}, options, level, _verbatim) when tag in @void_elements do
    [ make_indent(options, level), open_tag(tag, atts), maybe_add_newline(options) ]
  end
  defp _to_html(elements, options, level, verbatim) when is_list(elements) do
    elements
    |> Enum.map(&_to_html(&1, options, level, verbatim))
  end
  defp _to_html(element, options, _level, false) when is_binary(element) do
    escape(element, options)
  end
  defp _to_html(element, options, level, true) when is_binary(element) do
    [make_indent(options, level), element]
  end
  defp _to_html({"pre", atts, children, meta}, options, level, _verbatim) do
    verbatim = meta |> Map.get(:verbatim, false)
    [ make_indent(options, level),
      open_tag("pre", atts),
      _to_html(children, Map.put(options, :smartypants, false), level, verbatim),
      "</pre>", maybe_add_newline(options)]
  end
  defp _to_html({tag, atts, children, meta}, options, level, _verbatim) do
    verbatim = meta |> Map.get(:verbatim, false)
    [ make_indent(options, level),
      open_tag(tag, atts),
      maybe_add_newline(options),
      _to_html(children, options, level+1, verbatim),
      close_tag(tag, options, level)]
  end

  defp close_tag(tag, options, level) do
    [make_indent(options, level), "</", tag, ?>, maybe_add_newline(options)]
  end

  defp escape(element, options)
  defp escape("", _opions) do
    []
  end

  @dbl1_rgx ~r{(^|[-–—/\(\[\{"”“\s])'}
  @dbl2_rgx ~r{(^|[-–—/\(\[\{‘\s])\"}
  defp escape(element, %{smartypants: true}) do
    # Unfortunately these regexes still have to be left.
    # It doesn't seem possible to make escape_to_iodata
    # transform, for example, "--'" to "–‘" without
    # significantly complicating the code to the point
    # it outweights the performance benefit.
    element =
      element
      |> replace(@dbl1_rgx, "\\1‘")
      |> replace(@dbl2_rgx, "\\1“")

      escape_to_iodata(element, 0, element, [], true, 0)
  end

  defp escape(element, _options) do
      escape_to_iodata(element, 0, element, [], false, 0)
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
    [?<, tag, Enum.map(atts, &make_att(&1, tag)), " />"]
  end
  defp open_tag(tag, atts) do
    [?<, tag, Enum.map(atts, &make_att(&1, tag)), ?>]
  end

  # Optimized HTML escaping + smartypants, insipred by Plug.HTML
  # https://github.com/elixir-plug/plug/blob/v1.11.0/lib/plug/html.ex

  # Do not escape HTML entities
  defp escape_to_iodata("&#x" <> rest, skip, original, acc, smartypants, len) do
    escape_to_iodata(rest, skip, original, acc, smartypants, len + 3)
  end

  escapes = [
    {?<, "&lt;"},
    {?>, "&gt;"},
    {?&, "&amp;"},
    {?", "&quot;"},
    {?', "&#39;"}
  ]

  # Can't use character codes for multibyte unicode characters
  smartypants_escapes = [
    {"---", "—"},
    {"--", "–"},
    {?', "’"},
    {?", "”"},
    {"...", "…"}
  ]

  # These match only if `smartypants` is true
  for {match, insert} <- smartypants_escapes do
    # Unlike HTML escape matches, smartypants matches may contain more than one character
    match_length = if is_binary(match), do: byte_size(match), else: 1

    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, true, 0) do
      escape_to_iodata(rest, skip + unquote(match_length), original, [acc | unquote(insert)], true, 0)
    end

    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, true, len) do
      part = binary_part(original, skip, len)
      escape_to_iodata(rest, skip + len + unquote(match_length), original, [acc, part | unquote(insert)], true, 0)
    end
  end

  for {match, insert} <- escapes do
    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, smartypants, 0) do
      escape_to_iodata(rest, skip + 1, original, [acc | unquote(insert)], smartypants, 0)
    end

    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, smartypants, len) do
      part = binary_part(original, skip, len)
      escape_to_iodata(rest, skip + len + 1, original, [acc, part | unquote(insert)], smartypants, 0)
    end
  end

  defp escape_to_iodata(<<_char, rest::bits>>, skip, original, acc, smartypants, len) do
    escape_to_iodata(rest, skip, original, acc, smartypants, len + 1)
  end

  defp escape_to_iodata(<<>>, 0, original, _acc, _smartypants, _len) do
    original
  end

  defp escape_to_iodata(<<>>, skip, original, acc, _smartypants, len) do
    [acc | binary_part(original, skip, len)]
  end
end
