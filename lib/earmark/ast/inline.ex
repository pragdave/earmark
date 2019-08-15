defmodule Earmark.Ast.Inline do
  @moduledoc """
  Match and render inline sequences, passing each to the
  renderer.
  """

  alias Earmark.AstRenderer
  alias Earmark.Context
  alias Earmark.Error
  alias Earmark.Helpers.LinkParser
  import Earmark.Helpers
  import Earmark.Helpers.StringHelpers, only: [behead: 2]
  import Earmark.Helpers.AstHelpers
  import Earmark.Context, only: [set_value: 2, update_context: 0]
  import Earmark.Message, only: [add_messages: 2]

  @typep conversion_data :: {String.t, non_neg_integer(), Earmark.Context.t, boolean()}
  @doc false
  def conv(src) do
    _convert(src, 0, update_context(), true).value
  end
  @doc false
  def convert(src, lnb, context)
  def convert(list, lnb, context) when is_list(list),
    do: _convert(Enum.join(list, "\n"), lnb, context, true)
  def convert(src, lnb, context), do: _convert(src, lnb, context, true)

  defp _convert(src, current_lnb, context, use_linky?)
  defp _convert("", _, context, _), do: context
  defp _convert(src, current_lnb, context, use_linky?) do
    case _convert_next(src, current_lnb, context, use_linky?) do
      {src1, lnb1, context1, use_linky1?} -> IO.inspect {1040, context1.value}; _convert(src1, lnb1, context1, use_linky1?)
      x -> raise "Internal Conversion Error\n\n#{inspect x}"
    end
  end

  @linky_converter_names [
    :converter_for_link,
    :converter_for_reflink,
    :converter_for_footnote,
    :converter_for_nolink
  ]

  defp all_converters do
    [
      converter_for_escape: &converter_for_escape/1,
      converter_for_autolink: &converter_for_autolink/1,
      # converter_for_tag: &converter_for_tag/1,
      converter_for_link: &converter_for_link/1,
      converter_for_img: &converter_for_img/1,
      converter_for_reflink: &converter_for_reflink/1,
      converter_for_footnote: &converter_for_footnote/1,
      converter_for_nolink: &converter_for_nolink/1,
      # converter_for_strikethrough_gfm: &converter_for_strikethrough_gfm/1,
      converter_for_strong: &converter_for_strong/1,
      converter_for_em: &converter_for_em/1,
      converter_for_code: &converter_for_code/1,
      # converter_for_br: &converter_for_br/1,
      # converter_for_inline_ial: &converter_for_inline_ial/1,
      converter_for_pure_link: &converter_for_pure_link/1,
      converter_for_text: &converter_for_text/1
    ]

  end

  defp _convert_next(src, lnb, context, use_linky?) do
    converters = 
      if use_linky? do
        all_converters
      else
        all_converters |> Keyword.drop(@linky_converter_names)
      end
    _find_and_execute_converter({src, lnb, context, use_linky?}, converters)
  end

  @spec _find_and_execute_converter( conversion_data(), list ) :: conversion_data()
  defp _find_and_execute_converter({src, lnb, context, use_linky?}, converters) do
    converters
    |> Enum.find_value( fn {_converter_name, converter} -> converter.({src, lnb, context, use_linky?}) end)
  end

  defp converter_for_escape({src, lnb, context, use_linky?}) do
    if match = Regex.run(context.rules.escape, src) do
#      IO.inspect {1000, :for_escape, src}
      [match, escaped] = match
      {behead(src, match), lnb, prepend(context, escaped), use_linky?}
    end
  end

  @autolink_rgx ~r{^<([^ >]+(@|:\/)[^ >]+)>}
  defp converter_for_autolink({src, lnb, context, use_linky?}) do
    if match = Regex.run(@autolink_rgx, src) do
#      IO.inspect {1400, match}
      [match, link, protocol] = match
      {href, text} = convert_autolink(link, protocol)
      out = render_link(href, text)
#      IO.inspect {1401, out}
      {behead(src, match), lnb, prepend(context, out), use_linky?}
    end
  end

  @pure_link_rgx ~r{\Ahttps?://\S+\b}u
  @pure_link_depreaction_warning """
  The string "https://github.com/pragdave/earmark" will be rendered as a link if the option `pure_links` is enabled.
  This will be the case by default in version 1.4.
  Disable the option explicitly with `false` to avoid this message.
  """
  defp converter_for_pure_link({src, lnb, context, use_linky?}) do
    if context.options.pure_links do
      case Regex.run(@pure_link_rgx, src) do
        [ match ] ->
          out = render_link(match, match)
          {behead(src, match), lnb, prepend(context, out), use_linky?}
          _ -> nil
      end
    end
  end

  defp converter_for_tag({src, context, result, lnb}) do
    case Regex.run(context.rules.tag, src) do
      [match] ->
        out = context.options.do_sanitize.(match)
        {behead(src, match), context, prepend(result, out), lnb}

      _ ->
        nil
    end
  end

  defp converter_for_link({src, lnb, context, use_linky?}) do
    # IO.inspect {4000, src}
    if match = LinkParser.parse_link(src, lnb) do
#      IO.inspect {4010, match}
      unless is_image?(match) do
        {match1, text, href, title, messages} = match
        out = output_link(context, text, href, title, lnb)
        {behead(src, match1), lnb, prepend(context, out), use_linky?}
      end
    end
  end

  defp converter_for_img({src, lnb, context, use_linky?}) do
    # IO.inspect {4100, src}
    if match = LinkParser.parse_link(src, lnb) do
      if is_image?(match) do
        {match1, text, href, title, messages} = match
        out = render_image(text, href, title, lnb)
        {behead(src, match1), lnb, prepend(context, out), use_linky?}
      end
    end
  end

  defp converter_for_reflink({src, lnb, context, use_linky?}) do
    if match = Regex.run(context.rules.reflink, src) do
      {match, alt_text, id} =
        case match do
          [match, id, ""] -> {match, id, id}
          [match, alt_text, id] -> {match, alt_text, id}
        end |> IO.inspect

      # case reference_link(context, match, alt_text, id, lnb) do
      #   {:ok, out} -> {behead(src, match), context, prepend(result, out), lnb}
      #   _ -> nil
      # end
    end
  end

  defp converter_for_footnote({src, lnb, context, use_linky?}) do
    case Regex.run(context.rules.footnote, src) do
      [match, id] ->
        case footnote_link(context, match, id) do
          {:ok, out} -> {behead(src, match), lnb, prepend(context, out), use_linky?}
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp converter_for_nolink({src, lnb, context, use_linky?}) do
    case Regex.run(context.rules.nolink, src) do
      [match, id] ->
        case reference_link(context, match, id, id, lnb) do
          {:ok, out} -> {behead(src, match), lnb, prepend(context, out), use_linky?}
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp converter_for_strikethrough_gfm({src, context, result, lnb}) do
    if match = Regex.run(context.rules.strikethrough, src) do
      [match, content] = match
      out = AstRenderer.strikethrough(convert(content, lnb, context).value)
      {behead(src, match), context, prepend(result, out), lnb}
    end
  end

  defp converter_for_strong({src, lnb, context, use_linky?}) do
    if match = Regex.run(context.rules.strong, src) do
#      IO.inspect {1000, :for_strong, src}
      {match, content} =
        case match do
          [m, _, c] -> {m, c}
          [m, c] -> {m, c}
        end

      context1 = _convert(content, lnb, set_value(context, []), use_linky?)

      # IO.inspect context.value
      {behead(src, match), lnb, prepend(context, {"strong", [], context1.value|>Enum.reverse}), use_linky?}
    end
  end

  defp converter_for_em({src, lnb, context, use_linky?}) do
    if match = Regex.run(context.rules.em, src) do
#      IO.inspect {1000, :for_em, src}
      {match, content} =
        case match do
          [m, _, c] -> {m, c}
          [m, c] -> {m, c}
        end

      context1 = _convert(content, lnb, set_value(context, []), use_linky?)

      # IO.inspect context.value
      {behead(src, match), lnb, prepend(context, {"em", [], context1.value|>Enum.reverse}), use_linky?}
    end
  end

  @squash_ws ~r{\s+}
  defp converter_for_code({src, lnb, context, use_linky?}) do
    if match = Regex.run(context.rules.code, src) do
      [match, _, content] = match
      # Commonmark
      content1 = content
      |> String.trim()
      |> String.replace(@squash_ws, " ")
        
      # out = codespan(escape(content1, true) |> IO.inspect)
      out = codespan(content1) # |> IO.inspect)
      {behead(src, match), lnb, prepend(context, out), use_linky?}
    end
  end

  defp converter_for_inline_ial(conv_data)
  defp converter_for_inline_ial(
         {src, context, %{value: [maybe_tag | result]} = result_ctx, lnb}
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
  defp converter_for_inline_ial(_conv_data), do: nil

  defp converter_for_br({src, context, result, lnb}) do
    if match = Regex.run(context.rules.br, src, return: :index) do
      out = AstRenderer.br()
      [{0, match_len}] = match
      {behead(src, match_len), context, prepend(result, out), lnb}
    end
  end

  @spec converter_for_text( conversion_data() ) :: conversion_data() 
  defp converter_for_text({src, lnb, context, _}) do
#      IO.inspect {1000, :for_text, src}
    matched =
      case Regex.run(context.rules.text, src) do
        [match] -> match
      end

      # out =
      #   escape(context.options.do_smartypants.(match))
      #   |> hard_line_breaks(context.options.gfm)
      #   |> gruber_line_breaks()

#     IO.inspect {1001, matched}
    {behead(src, matched), lnb, prepend(context, matched), true}
  end

  defp convert_autolink(link, separator)
  defp convert_autolink(link, _separator = "@") do
    link = if String.at(link, 6) == ":", do: behead(link, 7), else: link
    text = link
    href = "mailto:" <> text
    {encode(href), text}
  end
  defp convert_autolink(link, _separator) do
    link = encode(link)
    {link, link}
  end

  @gruber_line_break Regex.compile!(" {2,}(?>\n)", "m")
  defp gruber_line_breaks(text) do
    Regex.replace(@gruber_line_break, text, AstRenderer.br())
  end

  @gfm_hard_line_break ~r{\\\n}
  defp hard_line_breaks(text, gfm)
  defp hard_line_breaks(text, false), do: text
  defp hard_line_breaks(text, nil), do: text
  defp hard_line_breaks(text, _) do
    Regex.replace(@gfm_hard_line_break, text, AstRenderer.br <> "\n")
  end

  defp output_image_or_link(context, link_or_image, text, href, title, lnb)
  defp output_image_or_link(context, "!" <> _, text, href, title, lnb) do
    render_image(text, href, title, lnb)
  end
  defp output_image_or_link(context, _, text, href, title, lnb) do
    output_link(context, text, href, title, lnb)
  end

  defp output_link(context, text, href, title, lnb) do
    href = encode(href, false)
    context1 = %{context | options: %{context.options | pure_links: false}}

    context2 = _convert(text, lnb, set_value(context1, []), false)
    if title do
      { "a", [{"href", href}, {"title", title}], context2.value }
    else
      { "a", [{"href", href}], context2.value }
    end
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
        {:ok, render_footnote_link("fn:#{number}", "fnref:#{number}", number)}
      _ ->
        nil
    end
  end

  defp is_image?({match_text, _, _, _}), do: String.starts_with?(match_text, "!")
  defp is_image?({match_text, _, _, _, _}), do: String.starts_with?(match_text, "!")
  @trailing_newlines ~r{\n*\z}


  defp prepend(%Context{value: value}=context, prep) do
#    IO.inspect {1001, value, prep}
    x=_prepend(context, prep)
#    IO.inspect {1002, x.value}
    x
  end
  defp _prepend(context, value)
  defp _prepend(%Context{value: [str|rest]=value}=context, prep) when is_binary(str) and is_binary(prep) do
    %{context | value: [str <> prep|rest]}
  end
  defp _prepend(%Context{value: value}=context, prep) do
    %{context | value: [prep | value]}
  end

  defp update_lnb(data = {_, _, %{value: []}, _}), do: data
  defp update_lnb({rest, context, result = %{value: [{head, _, _} | _]}, lnb}) do
    [suffix] = Regex.run(@trailing_newlines, head)
    {rest, context, result, lnb + String.length(suffix)}
  end
  defp update_lnb({rest, context, result = %{value: [head | _]}, lnb}) do
    [suffix] = Regex.run(@trailing_newlines, head)
    {rest, context, result, lnb + String.length(suffix)}
  end

end

# SPDX-License-Identifier: Apache-2.0
