defmodule Earmark.Inline do
  @moduledoc """
  Match and render inline sequences, passing each to the
  renderer.
  """

  alias Earmark.Error
  alias Earmark.Helpers.LinkParser
  import Earmark.Helpers
  import Earmark.Helpers.StringHelpers, only: [behead: 2]
  import Earmark.Helpers.HtmlHelpers, only: [augment_tag_with_ial: 4]
  import Earmark.Context, only: [prepend: 2, set_value: 2]
  import Earmark.Message, only: [add_messages: 2]

  @doc false
  def convert(src, lnb, context)

  def convert(list, lnb, context) when is_list(list),
    do: _convert(Enum.join(list, "\n"), lnb, context)

  def convert(src, lnb, context), do: _convert(src, lnb, context)

  defp _convert(src, current_lnb, context) do
    convert_each({src, context, %{context | value: []}, current_lnb}, all_converters(context.options))
  end

  @linky_converter_names [
    :converter_for_link,
    :converter_for_reflink,
    :converter_for_footnote,
    :converter_for_nolink
  ]

  defp all_converters(options) do
    [
      { :converter_for_escape, &converter_for_escape/2 },
      { :converter_for_autolink, &converter_for_autolink/2 },
      options.gfm && { :converter_for_purelink, &converter_for_purelink/2 },
      { :converter_for_tag, &converter_for_tag/2 },
      { :converter_for_link, &converter_for_link/2 },
      { :converter_for_img, &converter_for_img/2 },
      { :converter_for_reflink, &converter_for_reflink/2 },
      { :converter_for_footnote, &converter_for_footnote/2 },
      { :converter_for_nolink, &converter_for_nolink/2 },
      { :converter_for_strikethrough_gfm, &converter_for_strikethrough_gfm/2 },
      { :converter_for_strong, &converter_for_strong/2 },
      { :converter_for_em, &converter_for_em/2 },
      { :converter_for_code, &converter_for_code/2 },
      { :converter_for_br, &converter_for_br/2 },
      { :converter_for_inline_ial, &converter_for_inline_ial/2 },
      { :converter_for_text, &converter_for_text/2 },
    ]
    |> Enum.filter(&(&1))
  end

  defp convert_each(data, converters)
  defp convert_each({"", context, result, _lnb}, _converters) do
    with result1 <-
           result.value
           |> Enum.reverse()
           |> IO.iodata_to_binary()
           |> replace(~r{(</[^>]*>)‘}, "\\1’")
           |> replace(~r{(</[^>]*>)“}, "\\1”"),
         do: set_value(context, result1)
  end
  defp convert_each(data, converters) do
    walk_converters(converters, data, converters)
  end

  defp walk_converters(converters, data, all_converters)
  defp walk_converters([], _, _) do
    # This should never happen
    raise Error, "Illegal State"
  end
  defp walk_converters(
         [{_converter_name, converter} | rest],
         data = {_src, context, _result, _lnb},
         all_converters
       ) do
    case converter.(data, context.options.renderer) do
      # This has not been the correct converter, move on
      nil -> walk_converters(rest, data, all_converters)
      nd -> convert_each(update_lnb(nd), all_converters)
    end
  end

  defp converter_for_escape({src, context, result, lnb}, _renderer) do
    if match = Regex.run(context.rules.escape, src) do
      [match, escaped] = match
      {behead(src, match), context, prepend(result, escaped), lnb}
    end
  end

  defp converter_for_autolink({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.autolink, src) do
      [match, link, protocol] = match
      {href, text} = convert_autolink(link, protocol)
      out = renderer.link(href, text)
      {behead(src, match), context, prepend(result, out), lnb}
    end
  end

  @purelink_rgx ~r{\A(?:https?|mailto)://[a-zA-Z0-9%#/?&=-_.+!*'(),$]+}
  defp converter_for_purelink({src, context, result, lnb}, renderer) do
    # Moving away from storing rules inside %Earmark.Context{}
    case Regex.run(@purelink_rgx, src) do
      [href] -> as_link = renderer.link(href, href)
        {behead(src, href), context, prepend(result, as_link), lnb}
      _    -> nil
    end
  end

  defp converter_for_tag({src, context, result, lnb}, _renderer) do
    case Regex.run(context.rules.tag, src) do
      [match] ->
        out = context.options.do_sanitize.(match)
        {behead(src, match), context, prepend(result, out), lnb}

      _ ->
        nil
    end
  end

  defp converter_for_link({src, context, result, lnb}, _renderer) do
    if match = LinkParser.parse_link(src, lnb) do
      unless is_image?(match) do
        {match1, text, href, title, messages} = match
        out = output_link(context, text, href, title, lnb)
        {behead(src, match1), add_messages(context, messages), prepend(result, out), lnb}
      end
    end
  end

  defp converter_for_img({src, context, result, lnb}, _renderer) do
    if match = LinkParser.parse_link(src, lnb) do
      if is_image?(match) do
        {match1, text, href, title, messages} = match
        out = output_image(context.options.renderer, text, href, title)
        {behead(src, match1), add_messages(context, messages), prepend(result, out), lnb}
      end
    end
  end

  defp converter_for_reflink({src, context, result, lnb}, _renderer) do
    if match = Regex.run(context.rules.reflink, src) do
      {match, alt_text, id} =
        case match do
          [match, id, ""] -> {match, id, id}
          [match, alt_text, id] -> {match, alt_text, id}
        end

      case reference_link(context, match, alt_text, id, lnb) do
        {:ok, out} -> {behead(src, match), context, prepend(result, out), lnb}
        _ -> nil
      end
    end
  end

  defp converter_for_footnote({src, context, result, lnb}, _renderer) do
    case Regex.run(context.rules.footnote, src) do
      [match, id] ->
        case footnote_link(context, match, id) do
          {:ok, out} -> {behead(src, match), context, prepend(result, out), lnb}
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp converter_for_nolink({src, context, result, lnb}, _renderer) do
    case Regex.run(context.rules.nolink, src) do
      [match, id] ->
        case reference_link(context, match, id, id, lnb) do
          {:ok, out} -> {behead(src, match), context, prepend(result, out), lnb}
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp converter_for_strikethrough_gfm({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.strikethrough, src) do
      [match, content] = match
      out = renderer.strikethrough(convert(content, lnb, context).value)
      {behead(src, match), context, prepend(result, out), lnb}
    end
  end

  defp converter_for_strong({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.strong, src) do
      {match, content} =
        case match do
          [m, _, c] -> {m, c}
          [m, c] -> {m, c}
        end

      out = renderer.strong(convert(content, lnb, context).value)
      {behead(src, match), context, prepend(result, out), lnb}
    end
  end

  defp converter_for_em({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.em, src) do
      {match, content} =
        case match do
          [m, _, c] -> {m, c}
          [m, c] -> {m, c}
        end

      out = renderer.em(convert(content, lnb, context).value)
      {behead(src, match), context, prepend(result, out), lnb}
    end
  end

  @squash_ws ~r{\s+}
  defp converter_for_code({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.code, src) do
      [match, _, content] = match
      # Commonmark
      content1 = content
      |> String.trim()
      |> String.replace(@squash_ws, " ")
        
      out = renderer.codespan(escape(content1, true))
      {behead(src, match), context, prepend(result, out), lnb}
    end
  end

  defp converter_for_inline_ial(conv_data, renderer)

  defp converter_for_inline_ial(
         {src, context, %{value: [maybe_tag | result]} = result_ctx, lnb},
         _renderer
       ) do
    if match = Regex.run(context.rules.inline_ial, src) do
      [match, ial] = match

      case augment_tag_with_ial(context, maybe_tag, ial, lnb) do
        nil ->
          nil

        {context1, new_tag} ->
          {behead(src, match), context1, set_value(result_ctx, [new_tag | result]), lnb}
      end
    end
  end

  defp converter_for_inline_ial(_conv_data, _renderer), do: nil

  defp converter_for_br({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.br, src, return: :index) do
      out = renderer.br()
      [{0, match_len}] = match
      {behead(src, match_len), context, prepend(result, out), lnb}
    end
  end

  defp converter_for_text({src, context, result, lnb}, renderer) do
    if match = Regex.run(context.rules.text, src) do
      [match] = match

      out =
        escape(context.options.do_smartypants.(match))
        |> hard_line_breaks(context.options.gfm, renderer)
        |> gruber_line_breaks(renderer)

      {behead(src, match), context, prepend(result, out), lnb}
    end
  end

  defp convert_autolink(link, _separator = "@") do
    link = if String.at(link, 6) == ":", do: behead(link, 7), else: link
    text = mangle_link(link)
    href = mangle_link("mailto:") <> text
    {encode(href), escape(text)}
  end

  defp convert_autolink(link, _separator) do
    link = encode(link)
    {link, link}
  end

  @gruber_line_break Regex.compile!(" {2,}(?>\n)", "m")
  defp gruber_line_breaks(text, renderer) do
    Regex.replace(@gruber_line_break, text, renderer.br())
  end

  @gfm_hard_line_break ~r{\\\n}
  defp hard_line_breaks(text, gfm, renderer)
  defp hard_line_breaks(text, false, _renderer), do: text
  defp hard_line_breaks(text, nil, _renderer), do: text

  defp hard_line_breaks(text, _, renderer) do
    with br = renderer.br(), do: Regex.replace(@gfm_hard_line_break, text, br <> "\n")
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
    href = encode(href)
    title = if title, do: escape(title), else: nil

    link =
      convert_each(
        {text, context, set_value(context, []), lnb},
        Keyword.drop(all_converters(context.options), @linky_converter_names)
      )

    context.options.renderer.link(href, link.value, title)
  end

  defp output_footnote_link(context, ref, back_ref, number) do
    ref = encode(ref)
    back_ref = encode(back_ref)
    context.options.renderer.footnote_link(ref, back_ref, number)
  end

  @remove_escapes ~r{ \\ (?! \\ ) }x
  defp output_image(renderer, text, href, title) do
    href = encode(href)
    title = if title, do: escape(title), else: nil
    alt = text |> escape() |> String.replace(@remove_escapes, "")

    renderer.image(href, alt, title)
  end

  defp reference_link(context, match, alt_text, id, lnb) do
    id = id |> replace(~r{\s+}, " ") |> String.downcase()

    case Map.fetch(context.links, id) do
      {:ok, link} ->
        {:ok, output_image_or_link(context, match, alt_text, link.url, link.title, lnb)}

      _ ->
        nil
    end
  end

  defp footnote_link(context, _match, id) do
    case Map.fetch(context.footnotes, id) do
      {:ok, %{number: number}} ->
        {:ok, output_footnote_link(context, "fn:#{number}", "fnref:#{number}", number)}

      _ ->
        nil
    end
  end

  defp is_image?({match_text, _, _, _}), do: String.starts_with?(match_text, "!")
  defp is_image?({match_text, _, _, _, _}), do: String.starts_with?(match_text, "!")
  @trailing_newlines ~r{\n*\z}

  defp update_lnb(data = {_, _, %{value: []}, _}), do: data

  defp update_lnb({rest, context, result = %{value: [head | _]}, lnb}) do
    [suffix] = Regex.run(@trailing_newlines, head)
    {rest, context, result, lnb + String.length(suffix)}
  end
end

# SPDX-License-Identifier: Apache-2.0
