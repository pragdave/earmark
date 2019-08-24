defmodule Earmark.Ast.Inline do
  import Dev.Debugging, only: [inspectX: 1, inspectX: 2]

  @moduledoc """
  Match and render inline sequences, passing each to the
  renderer.
  """

  alias Earmark.AstRenderer
  alias Earmark.Context
  alias Earmark.Error
  alias Earmark.Helpers.LinkParser

  import Earmark.Ast.Renderer.AstWalker 
  import Earmark.Helpers
  import Earmark.Helpers.AttrParser
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
      {src1, lnb1, context1, use_linky1?} -> _convert(src1, lnb1, context1, use_linky1?)
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
      converter_for_br: &converter_for_br/1,
      converter_for_inline_ial: &converter_for_inline_ial/1,
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
       inspectX({4100, :for_escape, src})
      [match, escaped] = match
        inspectX(4101, escaped)
      {behead(src, match), lnb, prepend(context, escaped), use_linky?}
    end
  end

  @autolink_rgx ~r{^<([^ >]+(@|:\/)[^ >]+)>}
  defp converter_for_autolink({src, lnb, context, use_linky?}) do
    if match = Regex.run(@autolink_rgx, src) do
       inspectX(1400, match)
      [match, link, protocol] = match
      {href, text} = convert_autolink(link, protocol)
      out = render_link(href, text)
       inspectX(1401, out)
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
      inspectX(4000, src)
    if match = LinkParser.parse_link(src, lnb) do
       inspectX(4010, match)
      unless is_image?(match) do
        {match1, text, href, title, messages} = match
        out = output_link(context, text, href, title, lnb)
        {behead(src, match1), lnb, prepend(context, out), use_linky?}
      end
    end
  end

  defp converter_for_img({src, lnb, context, use_linky?}) do
    if match = LinkParser.parse_link(src, lnb) do
      inspectX({4100, :for_img, src})
      if is_image?(match) do
        {match1, text, href, title, messages} = match
        out = render_image(text, href, title, lnb)
        {behead(src, match1), lnb, prepend(context, out), use_linky?}
      end
    end
  end

  defp converter_for_reflink({src, lnb, context, use_linky?}) do
    if match = Regex.run(context.rules.reflink, src) do
      inspectX({4100, :for_reflink, src})
      {match, alt_text, id} =
        case match do
          [match, id, ""] -> {match, id, id}
          [match, alt_text, id] -> {match, alt_text, id}
        end |> inspectX(4101)

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
       inspectX({4100, :for_strong, src})
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
       inspectX({4100, :for_em, src})
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
       inspectX({4100, :for_code, src})
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
         {src, lnb, context, use_linky?}
       ) do
    if match = Regex.run(context.rules.inline_ial, src) do
       inspectX({4100, :inline_ial, src})
      [match, ial] = match
      {context1, ial_attrs} = parse_attrs(context, ial, lnb)
      inspectX({1060, ial_attrs, context.value, lnb})
      new_tags = augment_tag_with_ial(context.value, ial_attrs)
      {behead(src, match), lnb, set_value(context1, new_tags), use_linky?}
    end
  end
  defp converter_for_inline_ial(_conv_data), do: nil

  defp converter_for_br({src, lnb, context, use_linky?}) do
    if match = Regex.run(context.rules.br, src, return: :index) do
       inspectX({4100, :inline_br, src})
      [{0, match_len}] = match
      {behead(src, match_len), lnb, prepend(context, {"br", [], []}), use_linky?}
    end
  end

  @line_ending ~r{\r\n?|\n}
  @spec converter_for_text( conversion_data() ) :: conversion_data() 
  defp converter_for_text({src, lnb, context, _}) do
    matched =
      case Regex.run(context.rules.text, src) do
        [match] -> match
      end 


    line_count = matched |> String.split(@line_ending) |> Enum.count

    inspectX({4100, :text, src, matched, context.options.gfm})
    ast = hard_line_breaks(matched, context.options.gfm)
    inspectX(4101, ast)
    ast = walk_ast(ast, &gruber_line_breaks/1)
    inspectX(4102, ast)
    {behead(src, matched), lnb + line_count - 1, prepend(context, ast), true}
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
    text
    |> String.split(@gruber_line_break)
    |> Enum.intersperse({"br", [], []})
    |> _remove_leading_empty()
  end

  @gfm_hard_line_break ~r{\\\n}
  defp hard_line_breaks(text, gfm)
  defp hard_line_breaks(text, false), do: text
  defp hard_line_breaks(text, nil), do: text
  defp hard_line_breaks(text, _) do
    text
    |> String.split(@gfm_hard_line_break)
    |> Enum.intersperse({"br", [], []})
    |> _remove_leading_empty()
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
    inspectX({1001, value, prep})
    x=_prepend(context, prep)
    inspectX(1002, x.value)
    x
  end

  defp _prepend(context, value)
  defp _prepend(context, [bin|rest]) when is_binary(bin) do
    _prepend(_prepend(context, bin), rest)
  end
  defp _prepend(%Context{value: [str|rest]=value}=context, prep) when is_binary(str) and is_binary(prep) do
    %{context | value: [str <> prep|rest]}
  end
  defp _prepend(%Context{value: value}=context, prep) when is_list(prep) do
    %{context | value: Enum.reverse(prep) ++ value}
  end
  defp _prepend(%Context{value: value}=context, prep) do
    %{context | value: [prep | value]}
  end

  defp _remove_leading_empty(list)
  defp _remove_leading_empty([""|rest]), do: rest
  defp _remove_leading_empty(list), do: list

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
