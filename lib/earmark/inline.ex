 defmodule Earmark.Inline do

  @moduledoc """
  Match inline sequences and convert to blocks for the
  renderer to handle.
  """

  alias  Earmark.Error
  alias  Earmark.Helpers.LinkParser
  import Earmark.Helpers
  import Earmark.Helpers.StringHelpers, only: [behead: 2]
  import Earmark.Helpers.HtmlHelpers, only: [augment_tag_with_ial: 4]
  import Earmark.Context, only: [prepend: 2, set_value: 2]
  import Earmark.Message, only: [add_messages: 2, get_messages: 1]

  # @doc false
  def convert(src, lnb, context)
  # def convert(list, lnb, context) when is_list(list), do: _convert(Enum.join(list, "\n"), lnb, context)
  def convert(list, lnb, context) when is_list(list) do
    result_context = set_value(context, [])

    converted =
      flatten_inline_content(list)
      |> context.options.mapper.(&(_convert(&1, lnb, context)))

    all_values = Enum.reduce(converted, [], fn(ctx, values) -> values ++ ctx.value end) |> flatten_result
    result =
      converted
      |> Enum.reduce(fn(ctx, result_context) ->
        result_context = set_value(result_context, [ctx.value, result_context.value])
        add_messages(result_context, get_messages(ctx))
      end)

    set_value(result, flatten_result(result.value))
  end


  def convert(src, lnb, context),                     do: _convert(src, lnb, context)

  defp _convert(src, current_lnb, context) do
    out = convert_each({src, context, %{context | value: []}, current_lnb}, all_converters())
  end

  @linky_converter_names [:converter_for_link, :converter_for_reflink, :converter_for_footnote, :converter_for_nolink]

  defp all_converters do
    [
      converter_for_escape:             &converter_for_escape/2,
      converter_for_autolink:           &converter_for_autolink/2,
      converter_for_tag:                &converter_for_tag/2,
      converter_for_link:               &converter_for_link/2,
      converter_for_img:                &converter_for_img/2,
      converter_for_reflink:            &converter_for_reflink/2,
      converter_for_footnote:           &converter_for_footnote/2,
      converter_for_nolink:             &converter_for_nolink/2,
      converter_for_strikethrough_gfm:  &converter_for_strikethrough_gfm/2,
      converter_for_strong:             &converter_for_strong/2,
      converter_for_em:                 &converter_for_em/2,
      converter_for_code:               &converter_for_code/2,
      converter_for_br:                 &converter_for_br/2,
      converter_for_inline_ial:         &converter_for_inline_ial/2,
      converter_for_text:               &converter_for_text/2
    ]
  end

  defmodule Link,   do: defstruct href: nil, text: nil, title: nil, ial: %{}
  defmodule FnLink, do: defstruct ref: nil, back_ref: nil, number: nil, title: "see footnote", class_list: ["footnote"], ial: %{}
  defmodule Image,  do: defstruct href: nil, alt: nil, title: nil, ial: %{}
  defmodule Strikethrough, do: defstruct content: nil, ial: %{}
  defmodule Strong, do: defstruct content: nil, ial: %{}
  defmodule Em, do: defstruct content: nil, ial: %{}
  defmodule Codespan, do: defstruct content: nil, ial: %{}
  defmodule Br, do: defstruct []


  defp convert_each(data, converters)

  defp convert_each({"", context, result, _lnb}, _converters) do
    with result1 <- result.value
      |> clean_result()
      |> context.options.renderer.render_inline(context), do: set_value(context, result1)
  end


  defp convert_each(data, converters) do
    walk_converters(converters, data, converters)
  end


  defp walk_converters(converters, data, all_converters)

  defp walk_converters([], _, _) do
    # This should never happen
    raise Error, "Illegal State"
  end

  defp walk_converters(converters, data = { src = %{}, context, result, lnb }, all_converters) do
    convert_each({ "", context, prepend(result, src), lnb }, all_converters)
  end
  defp walk_converters([{converter_name, converter}|rest], data = { src, context, _result, _lnb}, all_converters) do
    case converter.(data, context.options.renderer) do
      # This has not been the correct converter, move on
      nil                -> walk_converters(rest, data, all_converters)
      nd                 ->
        convert_each(update_lnb(nd), all_converters)
    end
  end


  defp converter_for_escape({src, context, result, lnb}, _renderer) do
    if match = Regex.run(context.rules.escape, src) do
      [ match, escaped ] = match
      { behead(src, match), context, prepend(result, escaped), lnb }
    end
  end

  defp converter_for_autolink({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.autolink, src) do
      [ match, link, protocol ] = match
      { href, text } = convert_autolink(link, protocol)
      out = %Link{ href: href, text: text }
      { behead(src, match), context, prepend(result, out), lnb }
    end
  end

  defp converter_for_tag({src, context, result, lnb}, _renderer) do
    case Regex.run(context.rules.tag, src) do
      [ match ] ->
        out = context.options.do_sanitize.(match)
        { behead(src, match), context, prepend(result, out), lnb }
        _       -> nil
    end
  end

  # TODO: v1.3 Fix this `mess` where mess in
  #       as we need to parse the url part for nested (), and [] expressions (from issues #88 and #70, as well as #89 and #90, but
  #       the later two are _home made_)
  #       a regex will not do. As however we have to accept the following title strings (for backwards compatibility before v1.3)
  #                 [...](url "title")and still title")  --> title = ~s<title")and still title>
  #       yecc will not do (we are  not LALR-1 not even LALR-k or LR-k :@ !!!!)
  #       therefor this complicated recursive descent bailing out parser I did not want to write in the first place...
  #       Oh yes and of course I cannot even preparse the url part because of this e.g.
  #                 [...](url "((((((")
  defp converter_for_link({src, context, result, lnb}, _renderer) do
    if match = LinkParser.parse_link(src, lnb) do
      unless is_image?(match) do
        {match, text, href, title, messages} = match
        out = output_link(context, text, href, title, lnb)
        { behead(src, match), add_messages(context, messages), prepend(result, out), lnb }
      end
    end
  end

  defp converter_for_img({src, context, result, lnb}, _renderer) do
    if match = LinkParser.parse_link(src, lnb) do
      if is_image?(match) do
        {match, text, href, title, messages} = match
        out = output_image(context.options.renderer, text, href, title)
        { behead(src, match), add_messages(context, messages), prepend(result,  out), lnb }
      end
    end
  end

  defp converter_for_reflink({src, context, result, lnb}, _renderer) do
    if match = Regex.run(context.rules.reflink, src) do
      { match, alt_text, id } = case match do
        [ match, id, "" ]       -> { match, id, id  }
        [ match, alt_text, id ] -> { match, alt_text, id }
      end
      case reference_link(context, match, alt_text, id, lnb) do
        {:ok, out} -> { behead(src, match), context, prepend(result,  out), lnb }
        _          -> nil
        end
      end
    end

  defp converter_for_footnote({src, context, result, lnb}, _renderer) do
    case Regex.run(context.rules.footnote, src) do
      [match, id] ->
        case footnote_link(context, match, id) do
          {:ok, out} -> { behead(src, match), context, prepend(result,  out), lnb }
          _          -> nil
        end
      _           -> nil
    end
  end

  defp converter_for_nolink({src, context, result, lnb}, _renderer) do
    case Regex.run(context.rules.nolink, src) do
      [ match, id ] ->
        case reference_link(context, match, id, id, lnb) do
            {:ok, out} -> { behead(src, match), context, prepend(result,  out), lnb }
            _          -> nil
        end
      _             -> nil
    end
  end

  defp converter_for_strikethrough_gfm({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.strikethrough, src) do
      [ match, content ] = match
      out = %Strikethrough{ content: convert(content, lnb, context).value }
      { behead(src, match), context, prepend(result,  out), lnb }
    end
  end

  defp converter_for_strong({src, context, result, lnb}, _renderer) do
    if match = Regex.run(context.rules.strong, src) do
      { match, content } = case match do
        [ m, _, c ] -> {m, c}
        [ m, c ]    -> {m, c}
      end
      out = %Strong{ content: convert(content, lnb, context).value }
      { behead(src, match), context, prepend(result,  out), lnb }
    end
  end

  defp converter_for_em({src, context, result, lnb}, _renderer) do
    if match = Regex.run(context.rules.em, src) do
      { match, content } = case match do
        [ m, _, c ] -> {m, c}
        [ m, c ]    -> {m, c}
      end
      out = %Em{ content: convert(content, lnb, context).value }
      { behead(src, match), context, prepend(result,  out), lnb }
    end
  end

  defp converter_for_code({src, context, result, lnb}, _renderer) do
    if match = Regex.run(context.rules.code, src) do
      [match, _, content] = match
      content = String.trim(content)  # this from Gruber
      out = %Codespan{ content: escape(content, true) }
      { behead(src, match), context, prepend(result,  out), lnb }
    end
  end

  defp converter_for_inline_ial(conv_data, renderer)
  defp converter_for_inline_ial({src, context, %{value: [maybe_tag|result]}=result_ctx, lnb}, _renderer) do
    if match = Regex.run(context.rules.inline_ial, src) do
      [match, ial] = match
      case augment_tag_with_ial(context, maybe_tag, ial, lnb) do
        nil                 -> nil
        {context1, new_tag} ->
          { behead(src, match), context1, set_value(result_ctx, [new_tag|result]), lnb }
      end
    end
  end
  defp converter_for_inline_ial(_conv_data, _renderer), do: nil

  defp converter_for_br({src, context, result, lnb}, _renderer) do
    if match = Regex.run(context.rules.br, src, return: :index) do
      out = %Br{}
      [ {0, match_len} ] = match
      { behead(src, match_len), context, prepend(result,  out), lnb }
    end
  end

  defp converter_for_text({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.text, src) do
      [ match ] = match
      out = escape(context.options.do_smartypants.(match))
      |> hard_line_breaks(context.options.gfm, renderer)
      { behead(src, match), context, prepend(result,  out), lnb }
    end
  end

  defp convert_autolink(link, _separator = "@") do
    link = (if String.at(link, 6) == ":", do: behead(link, 7), else: link)
    text = mangle_link(link)
    href = mangle_link("mailto:") <> text
    { encode(href), text }
  end

  defp convert_autolink(link, _separator) do
    link = encode(link)
    { link, link }
  end

  @gfm_hard_line_break ~r{\\\n}
  defp hard_line_breaks(text, gfm, renderer)
  defp hard_line_breaks(text, false, _renderer), do: text
  defp hard_line_breaks(text, nil, _renderer),   do: text
  defp hard_line_breaks(text, _, renderer) do
    # Return a list, replacing all \\n
    #
    Regex.split(@gfm_hard_line_break, text)
    |> Stream.with_index
    |> Enum.reduce([], fn
      {part, 0}, acc -> [part | acc]
      {part, idx}, acc -> [%Br{} | ["\n" | [part | acc]]]
    end)
  end


  @doc false
  def mangle_link(link) do
    link
  end

  defp output_image_or_link(context, "!" <> _, text, href, title, _lnb) do
    output_image(context.options.renderer, text, href, title)
  end

  defp output_image_or_link(context, _, text, href, title, lnb) do
    output_link(context, text, href, title, lnb)
  end

  defp output_link(context, text, href, title, lnb) do
    href       = encode(href)
    title      = if title, do: escape(title), else: nil
    link       = convert_each({text, context, set_value(context, []), lnb},
                        Keyword.drop(all_converters(), @linky_converter_names))

    %Link{ href: href, text: link.value, title: title }
  end

  defp output_footnote_link(context, ref, back_ref, number) do
    ref = encode(ref)
    back_ref = encode(back_ref)
    %FnLink{ ref: ref, back_ref: back_ref, number: number }
  end

  defp output_image(renderer, text, href, title) do
    href = encode(href)
    title = if title, do: escape(title), else: nil
    %Image{ href: href, alt: escape(text), title: title }
  end

  defp reference_link(context, match, alt_text, id, lnb) do
    id = id |> replace(~r{\s+}, " ") |> String.downcase

    case Map.fetch(context.links, id) do
      {:ok, link } -> {:ok, output_image_or_link(context, match, alt_text, link.url, link.title, lnb)}
      _            -> nil
      end
  end

  defp footnote_link(context, _match, id) do
    case Map.fetch(context.footnotes, id) do
      {:ok, %{number: number}} -> {:ok, output_footnote_link(context, "fn:#{number}", "fnref:#{number}", number)}
      _                        -> nil
    end
  end


  defp is_image?( {match_text, _, _, _} ), do: String.starts_with?(match_text, "!")
  defp is_image?( {match_text, _, _, _, _} ), do: String.starts_with?(match_text, "!")
  @trailing_newlines ~r{\n*\z}

  defp update_lnb(data = {_, _, %{value: []}, _}), do: data
  defp update_lnb({rest, context, result = %{value: [head|_]}, lnb}) when is_binary(head) do
    [suffix] = Regex.run(@trailing_newlines, head)
    { rest, context, result, lnb + String.length(suffix) }
  end
  defp update_lnb({rest, context, result = %{value: text}, lnb}) do
    { rest, context, result, lnb }
  end

  defp flatten_inline_content(list) do
    flatten_inline_content(list, [])
  end

  defp flatten_inline_content([], result), do: Enum.reverse(result)
  defp flatten_inline_content([head|rest], [last|result]) when is_binary(head) and is_binary(last) do
    flatten_inline_content(rest, [last <> "\n"  <> head | result])
  end
  defp flatten_inline_content([head|rest], result), do: flatten_inline_content(rest, [head|result])

  defp clean_result(result) do
    clean_result(result, [])
  end

  defp clean_result([], cleaned), do: Enum.reverse(cleaned)
  defp clean_result([clean | rest], cleaned) when is_binary(clean) do
    result =
      case List.first(rest) do
        %{} ->
          clean
          |> replace(~r{‘}, "\\1’")
          |> replace(~r{“}, "\\1”")

        _ -> clean
      end

    clean_result(rest, [result | cleaned])
  end

  defp clean_result([clean | rest], cleaned) do
    clean_result(rest, [clean | cleaned])
  end

  defp flatten_result(result) when length(result) == 1, do: hd(result)
  defp flatten_result(result), do: result
end

# SPDX-License-Identifier: Apache-2.0
