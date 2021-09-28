defmodule Earmark.Transform do

  import Earmark.Helpers, only: [replace: 3]

  alias Earmark.Options
  alias Earmark.TagSpecificProcessors, as: TSP

  @compact_tags ~w[a code em strong del]

  # https://www.w3.org/TR/2011/WD-html-markup-20110113/syntax.html#void-element
  @void_elements ~W(area base br col command embed hr img input keygen link meta param source track wbr)

  @moduledoc ~S"""
  #### Structure Conserving Transformers

  For the convenience of processing the output of `EarmarkParser.as_ast` we expose two structure conserving
  mappers.

  ##### `map_ast`

  takes a function that will be called for each node of the AST, where a leaf node is either a quadruple
  like `{"code", [{"class", "inline"}], ["some code"], %{}}` or a text leaf like `"some code"`

  The result of the function call must be

  - for nodes → a quadruple of which the third element will be ignored -- that might change in future,
  and will therefore classically be `nil`. The other elements replace the node

  - for strings → strings

  A third parameter `ignore_strings` which defaults to `false` can be used to avoid invocation of the mapper
  function for text nodes

  As an example let us transform an ast to have symbol keys

        iex(1)> input = [
        ...(1)> {"h1", [], ["Hello"], %{title: true}},
        ...(1)> {"ul", [], [{"li", [], ["alpha"], %{}}, {"li", [], ["beta"], %{}}], %{}}]
        ...(1)> map_ast(input, fn {t, a, _, m} -> {String.to_atom(t), a, nil, m} end, true)
        [ {:h1, [], ["Hello"], %{title: true}},
          {:ul, [], [{:li, [], ["alpha"], %{}}, {:li, [], ["beta"], %{}}], %{}} ]

  **N.B.** If this returning convention is not respected `map_ast` might not complain, but the resulting
  transformation might not be suitable for `Earmark.Transform.transform` anymore. From this follows that
  any function passed in as value of the `postprocessor:` option must obey to these conventions.

  ##### `map_ast_with`

  this is like `map_ast` but like a reducer an accumulator can also be passed through.

  For that reason the function is called with two arguments, the first element being the same value
  as in `map_ast` and the second the accumulator. The return values need to be equally augmented
  tuples.

  A simple example, annotating traversal order in the meta map's `:count` key, as we are not
  interested in text nodes we use the fourth parameter `ignore_strings` which defaults to `false`

         iex(2)>  input = [
         ...(2)>  {"ul", [], [{"li", [], ["one"], %{}}, {"li", [], ["two"], %{}}], %{}},
         ...(2)>  {"p", [], ["hello"], %{}}]
         ...(2)>  counter = fn {t, a, _, m}, c -> {{t, a, nil, Map.put(m, :count, c)}, c+1} end
         ...(2)>  map_ast_with(input, 0, counter, true)
         {[ {"ul", [], [{"li", [], ["one"], %{count: 1}}, {"li", [], ["two"], %{count: 2}}], %{count: 0}},
           {"p", [], ["hello"], %{count: 3}}], 4}

  #### Postprocessors and Convenience Functions

  These can be declared in the fields `postprocessor` and `registered_processors` in the `Options` struct,
  `postprocessor` is prepened to `registered_processors` and they are all applied to non string nodes (that
  is the quadtuples of the AST which are of the form `{tag, atts, content, meta}`

  All postprocessors can just be functions on nodes or a `TagSpecificProcessors` struct which will group
  function applications depending on tags, as a convienience tuples of the form `{tag, function}` will be
  transformed into a `TagSpecificProcessors` struct.

      iex(3)> add_class1 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class1")
      ...(3)> m1 = Earmark.Options.make_options!(postprocessor: add_class1) |> make_postprocessor()
      ...(3)> m1.({"a", [], nil, nil})
      {"a", [{"class", "class1"}], nil, nil}

  We can also use the `registered_processors` field:

      iex(4)> add_class1 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class1")
      ...(4)> m2 = Earmark.Options.make_options!(registered_processors: add_class1) |> make_postprocessor()
      ...(4)> m2.({"a", [], nil, nil})
      {"a", [{"class", "class1"}], nil, nil}

  Knowing that values on the same attributes are added onto the front the following doctest demonstrates
  the order in which the processors are executed

      iex(5)> add_class1 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class1")
      ...(5)> add_class2 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class2")
      ...(5)> add_class3 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class3")
      ...(5)> m = Earmark.Options.make_options!(postprocessor: add_class1, registered_processors: [add_class2, {"a", add_class3}])
      ...(5)> |> make_postprocessor()
      ...(5)> [{"a", [{"class", "link"}], nil, nil}, {"b", [], nil, nil}]
      ...(5)> |> Enum.map(m)
      [{"a", [{"class", "class3 class2 class1 link"}], nil, nil}, {"b", [{"class", "class2 class1"}], nil, nil}]

  We can see that the tuple form has been transformed into a tag specific transformation **only** as a matter of fact, the explicit definition would be:

      iex(6)> m = make_postprocessor(
      ...(6)>   %Earmark.Options{
      ...(6)>     registered_processors:
      ...(6)>       [Earmark.TagSpecificProcessors.new({"a", &Earmark.AstTools.merge_atts_in_node(&1, target: "_blank")})]})
      ...(6)> [{"a", [{"href", "url"}], nil, nil}, {"b", [], nil, nil}]
      ...(6)> |> Enum.map(m)
      [{"a", [{"href", "url"}, {"target", "_blank"}], nil, nil}, {"b", [], nil, nil}]

  We can also define a tag specific transformer in one step, which might (or might not) solve potential performance issues
  when running too many processors

      iex(7)> add_class4 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class4")
      ...(7)> add_class5 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class5")
      ...(7)> add_class6 = &Earmark.AstTools.merge_atts_in_node(&1, class: "class6")
      ...(7)> tsp = Earmark.TagSpecificProcessors.new([{"a", add_class5}, {"b", add_class5}])
      ...(7)> m = Earmark.Options.make_options!(
      ...(7)>       postprocessor: add_class4,
      ...(7)>       registered_processors: [tsp, add_class6])
      ...(7)> |> make_postprocessor()
      ...(7)> [{"a", [], nil, nil}, {"c", [], nil, nil}, {"b", [], nil, nil}]
      ...(7)> |> Enum.map(m)
      [{"a", [{"class", "class6 class5 class4"}], nil, nil}, {"c", [{"class", "class6 class4"}], nil, nil}, {"b", [{"class", "class6 class5 class4"}], nil, nil}]

  Of course the mechanics shown above is hidden if all we want is to trigger the postprocessor chain in `Earmark.as_html`, here goes a typical
  example

      iex(8)> add_target = fn node -> # This will only be applied to nodes as it will become a TagSpecificProcessors
      ...(8)>   if Regex.match?(~r{\.x\.com\z}, Earmark.AstTools.find_att_in_node(node, "href", "")), do:
      ...(8)>     Earmark.AstTools.merge_atts_in_node(node, target: "_blank"), else: node end
      ...(8)> options = [
      ...(8)> registered_processors: [{"a", add_target}, {"p", &Earmark.AstTools.merge_atts_in_node(&1, class: "example")}]]
      ...(8)> markdown =
      ...(8)> """
      ...(8)>   http://hello.x.com
      ...(8)>
      ...(8)>   [some](url)
      ...(8)> """
      ...(8)> Earmark.as_html!(markdown, options)
      "<p class=\"example\">\n  <a href=\"http://hello.x.com\" target=\"_blank\">http://hello.x.com</a></p>\n<p class=\"example\">\n  <a href=\"url\">some</a></p>\n"

  ##### Use case: Modification of Link Attributes depending on the URL

  This would be done as follows

  ```elixir
          Earmark.as_html!(markdown, registered_processors: {"a", my_function_that_is_invoked_only_with_a_nodes})
  ```

  ##### Use case: Modification of the AST according to Annotations

  **N.B.** Annotation are an _experimental_ feature in 1.4.16-pre and are documented [here](https://github.com/RobertDober/earmark_parser/#annotations)

  By annotating our markdown source we can then influence the rendering. In this example we will just
  add some decoration

      iex(9)> markdown = [ "A joke %% smile", "", "Charming %% in_love" ]
      ...(9)> add_smiley = fn {_, _, _, meta} = quad, _acc ->
      ...(9)>                case Map.get(meta, :annotation) do
      ...(9)>                  "%% smile"   -> {quad, "\u1F601"}
      ...(9)>                  "%% in_love" -> {quad, "\u1F60d"}
      ...(9)>                  _            -> {quad, nil}
      ...(9)>                end
      ...(9)>                text, nil -> {text, nil}
      ...(9)>                text, ann -> {"#{text} #{ann}", nil}
      ...(9)>              end
      ...(9)> Earmark.as_ast!(markdown, annotations: "%%") |> Earmark.Transform.map_ast_with(nil, add_smiley) |> Earmark.transform
      "<p>\nA joke  ὠ1</p>\n<p>\nCharming  ὠd</p>\n"

  #### Structure Modifying Transformers

  For structure modifications a tree traversal is needed and no clear pattern of how to assist this task with
  tools has emerged yet.


  """

  def make_postprocessor(options)
  def make_postprocessor(%{postprocessor: nil, registered_processors: rps}), do: _make_postprocessor(rps)
  def make_postprocessor(%{postprocessor: pp, registered_processors: rps}), do: _make_postprocessor([pp|rps])

  @doc """
  Transforms an AST to html, also accepts the result of `map_ast_with` for convenience
  """
  def transform(ast, options \\ %{initial_indent: 0, indent: 2})
  def transform({ast, _}, options), do: transform(ast, options)
  def transform(ast, options) when is_list(options) do
    transform(ast, options|>Enum.into(%{initial_indent: 0, indent: 2}))
  end
  def transform(ast, options) when is_map(options) do
    options1 = options
      |> Map.put_new(:indent, 2)
    ast
    # |> IO.inspect
    |> _maybe_remove_paras(options1)
    |> to_html(options1)
  end

  @doc ~S"""
  This is a structure conserving transformation

      iex(10)> {:ok, ast, _} = EarmarkParser.as_ast("- one\n- two\n")
      ...(10)> map_ast(ast, &(&1))
      [{"ul", [], [{"li", [], ["one"], %{}}, {"li", [], ["two"], %{}}], %{}}]

  A more useful transformation
      iex(11)> {:ok, ast, _} = EarmarkParser.as_ast("- one\n- two\n")
      ...(11)> fun = fn {_, _, _, _}=n -> Earmark.AstTools.merge_atts_in_node(n, class: "private")
      ...(11)>           string      -> string end
      ...(11)> map_ast(ast, fun)
      [{"ul", [{"class", "private"}], [{"li", [{"class", "private"}], ["one"], %{}}, {"li", [{"class", "private"}], ["two"], %{}}], %{}}]

  However the usage of the `ignore_strings` option renders the code much simpler

      iex(12)> {:ok, ast, _} = EarmarkParser.as_ast("- one\n- two\n")
      ...(12)> map_ast(ast, &Earmark.AstTools.merge_atts_in_node(&1, class: "private"), true)
      [{"ul", [{"class", "private"}], [{"li", [{"class", "private"}], ["one"], %{}}, {"li", [{"class", "private"}], ["two"], %{}}], %{}}]
  """
  def map_ast(ast, fun, ignore_strings \\ false) do
    _walk_ast(ast, fun, ignore_strings, [])
  end

  @doc ~S"""
  This too is a structure perserving transformation but a value is passed to the mapping function as an accumulator, and the mapping
  function needs to return the new node and the accumulator as a tuple, here is a simple example

      iex(13)> {:ok, ast, _} = EarmarkParser.as_ast("- 1\n\n2\n- 3\n")
      ...(13)> summer = fn {"li", _, [v], _}=n, s -> {v_, _} = Integer.parse(v); {n, s + v_}
      ...(13)>             n, s -> {n, s} end
      ...(13)> map_ast_with(ast, 0, summer, true)
      {[{"ul", [], [{"li", [], ["1"], %{}}], %{}}, {"p", [], ["2"], %{}}, {"ul", [], [{"li", [], ["3"], %{}}], %{}}], 4}

  or summing all numbers

      iex(14)> {:ok, ast, _} = EarmarkParser.as_ast("- 1\n\n2\n- 3\n")
      ...(14)> summer = fn {_, _, _, _}=n, s -> {n, s}
      ...(14)>             n, s -> {n_, _} = Integer.parse(n); {"*", s+n_} end
      ...(14)> map_ast_with(ast, 0, summer)
      {[{"ul", [], [{"li", [], ["*"], %{}}], %{}}, {"p", [], ["*"], %{}}, {"ul", [], [{"li", [], ["*"], %{}}], %{}}], 6}

  """
  def map_ast_with(ast, value, fun, ignore_strings \\ false) do
    _walk_ast_with(ast, value, fun, ignore_strings, [])
  end

  defp _make_postprocessor(processors) do
    processors_ = processors
    |> Enum.map( fn %TSP{}=tsp -> TSP.make_postprocessor(tsp)
                    just_a_fun -> just_a_fun end)
    fn node ->
      processors_
      |> Enum.reduce(node, fn processor, node -> processor.(node) end)
    end
  end

  defp maybe_add_newline(options)
  defp maybe_add_newline(%Options{compact_output: true}), do: []
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
  defp escape(element, %{smartypants: true} = options) do
    # Unfortunately these regexes still have to be left.
    # It doesn't seem possible to make escape_to_iodata
    # transform, for example, "--'" to "–‘" without
    # significantly complicating the code to the point
    # it outweights the performance benefit.
    element =
      element
      |> replace(@dbl1_rgx, "\\1‘")
      |> replace(@dbl2_rgx, "\\1“")

    escape = Map.get(options, :escape, true)
    escape_to_iodata(element, 0, element, [], true, escape, 0)
  end

  defp escape(element, %{escape: escape}) do
      escape_to_iodata(element, 0, element, [], false, escape, 0)
  end

  defp escape(element, _options) do
      escape_to_iodata(element, 0, element, [], false, true, 0)
  end

  defp make_att(name_value_pair, tag)
  defp make_att({name, value}, _) do
    [" ", name, "=\"", value, "\""]
  end

  defp make_indent(options, level)
  defp make_indent(%Options{compact_output: true}, _level) do
    ""
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
  defp escape_to_iodata("&#x" <> rest, skip, original, acc, smartypants, escape, len) do
    escape_to_iodata(rest, skip, original, acc, smartypants, escape, len + 3)
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

    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, true, escape, 0) do
      escape_to_iodata(rest, skip + unquote(match_length), original, [acc | unquote(insert)], true, escape, 0)
    end

    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, true, escape, len) do
      part = binary_part(original, skip, len)
      escape_to_iodata(rest, skip + len + unquote(match_length), original, [acc, part | unquote(insert)], true, escape, 0)
    end
  end

  for {match, insert} <- escapes do
    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, smartypants, true, 0) do
      escape_to_iodata(rest, skip + 1, original, [acc | unquote(insert)], smartypants, true, 0)
    end

    defp escape_to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, smartypants, true, len) do
      part = binary_part(original, skip, len)
      escape_to_iodata(rest, skip + len + 1, original, [acc, part | unquote(insert)], smartypants, true, 0)
    end
  end

  defp escape_to_iodata(<<_char, rest::bits>>, skip, original, acc, smartypants, escape, len) do
    escape_to_iodata(rest, skip, original, acc, smartypants, escape, len + 1)
  end

  defp escape_to_iodata(<<>>, 0, original, _acc, _smartypants, _escape, _len) do
    original
  end

  defp escape_to_iodata(<<>>, skip, original, acc, _smartypants, _escape, len) do
    [acc | binary_part(original, skip, len)]
  end

  defp _add_trailing_nl(node)
  defp _add_trailing_nl(text) when is_binary(text), do: [text, "\n"]
  defp _add_trailing_nl(node), do: node

  defp _maybe_remove_paras(ast, options)
  defp _maybe_remove_paras(ast, %Options{inner_html: true}) do
    Enum.map(ast, &_remove_para/1)
  end
  defp _maybe_remove_paras(ast, _), do: ast

  @pop {:__end__}
  defp _pop_to_pop(result, intermediate \\ [])
  defp _pop_to_pop([@pop, {tag, atts, _, meta}|rest], intermediate) do
    [{tag, atts, intermediate, meta}|rest]
  end
  defp _pop_to_pop([continue|rest], intermediate) do
    _pop_to_pop(rest, [continue|intermediate])
  end

  defp _remove_para(ele_or_string)
  defp _remove_para({"p", _, content, _}), do: content |> Enum.map(&_add_trailing_nl/1)
  defp _remove_para(whatever), do: whatever

  defp _walk_ast(ast, fun, ignore_strings, result)
  defp _walk_ast([], _fun, _ignore_strings, result), do: Enum.reverse(result)
  defp _walk_ast([[]|rest], fun, ignore_strings, result) do
    _walk_ast(rest, fun, ignore_strings, _pop_to_pop(result))
  end
  defp _walk_ast([string|rest], fun, ignore_strings, result) when is_binary(string) do
    new = if ignore_strings, do: string, else: fun.(string)
    _walk_ast(rest, fun, ignore_strings, [new|result])
  end
  defp _walk_ast([{_, _, content, _}=tuple|rest], fun, ignore_strings, result) do
    {new_tag, new_atts, _, new_meta} = fun.(tuple)
    _walk_ast([content|rest], fun, ignore_strings, [@pop, {new_tag, new_atts, [], new_meta}|result])
  end
  defp _walk_ast([[h|t]|rest], fun, ignore_strings, result) do
    _walk_ast([h, t|rest], fun, ignore_strings, result)
  end

  defp _walk_ast_with(ast, value, fun, ignore_strings, result)
  defp _walk_ast_with([], value, _fun, _ignore_strings, result), do: {Enum.reverse(result), value}
  defp _walk_ast_with([[]|rest], value, fun, ignore_strings, result) do
    _walk_ast_with(rest, value, fun, ignore_strings, _pop_to_pop(result))
  end
  defp _walk_ast_with([string|rest], value, fun, ignore_strings, result) when is_binary(string) do
    if ignore_strings do
      _walk_ast_with(rest, value, fun, ignore_strings, [string|result])
    else
      {news, newv} = fun.(string, value)
      _walk_ast_with(rest, newv, fun, ignore_strings, [news|result])
    end
  end
  defp _walk_ast_with([{_, _, content, _}=tuple|rest], value, fun, ignore_strings, result) do
    {{new_tag, new_atts, _, new_meta}, new_value} = fun.(tuple, value)
    _walk_ast_with([content|rest], new_value, fun, ignore_strings, [@pop, {new_tag, new_atts, [], new_meta}|result])
  end
  defp _walk_ast_with([[h|t]|rest], value, fun, ignore_strings, result) do
    _walk_ast_with([h, t|rest], value, fun, ignore_strings, result)
  end
end
#  SPDX-License-Identifier: Apache-2.0
