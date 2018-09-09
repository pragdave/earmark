defmodule Earmark.Renderers.ASTRenderer do

  alias  Earmark.Block
  alias  Earmark.Context
  alias  Earmark.Options
  alias Earmark.Inline
  import Earmark.Helpers, only: [ escape: 2 ]
  import Earmark.Inline,  only: [ convert: 3 ]
  import Earmark.Message, only: [ add_messages_from: 2, add_messages: 2, get_messages: 1 ]
  import Earmark.Helpers.AttrParser
  import Earmark.Context, only: [ prepend: 2, append: 2, set_value: 2 ]

  def render(blocks, context=%Context{options: %Options{mapper: mapper}}) do
    messages = get_messages(context)

    {contexts, ast} =
    mapper.(blocks, &(render_block(&1, put_in(context.options.messages, [])))) |> Enum.unzip()

    all_messages =
      contexts
      |> Enum.reduce( messages, fn (ctx, messages1) ->  messages1 ++ get_messages(ctx) end)

    ast = ast |> Enum.reject(&is_nil/1) |> flatten_ast
    {put_in(context.options.messages, all_messages), ast}
  end

  def render_inline(blocks, context=%Context{options: %Options{mapper: mapper}}) do
    result = blocks
    |> mapper.(&(render_block(&1, context)))
    |> Enum.reverse()
    |> Enum.chunk_by(&(is_binary(&1)))
    |> Enum.map(&(clean_inline_chunk(&1)))
  end

  defp render_ast(blocks, context=%Context{options: %Options{mapper: mapper}}) do
    {contexts, ast} =
    mapper.(blocks, &(render_block(&1, put_in(context.options.messages, [])))) |> Enum.unzip()

    ast
  end

  defp flatten_ast(ast) when length(ast) == 1 do
    hd(ast)
  end

  defp flatten_ast(ast), do: List.flatten(ast)

  #############
  # Paragraph #
  #############

  defp render_block(block=%Block.Para{lnb: lnb, lines: lines, attrs: attrs}, context) do
    lines = convert(lines, lnb, context)
    values = [lines]
      |> List.flatten
      |> Enum.map(&(&1.value))
      |> List.flatten
      |> Enum.map(fn
           line = " " -> line
           line when is_binary(line) -> Floki.parse(line)
           line -> line
         end)
      |> List.flatten

    { lines, build_ast(lines, "p", normalise_attrs(lines, attrs, lnb), values) }
  end

  ########
  # Html #
  ########
  defp render_block(%Block.Html{html: html}, context) do
    { context, Floki.parse(html) }
  end

  defp render_block(%Block.HtmlOther{html: html}, context) do
    { context, Floki.parse(html) }
  end

  #########
  # Ruler #
  #########
  defp render_block(%Block.Ruler{lnb: lnb, type: "-", attrs: attrs}, context) do
    { context, build_ast(context, "hr", Enum.concat(normalise_attrs(context, attrs), [{"class", "thin"}])) }
  end

  defp render_block(%Block.Ruler{lnb: lnb, type: "_", attrs: attrs}, context) do
    { context, build_ast(context, "hr", Enum.concat(normalise_attrs(context, attrs), [{"class", "medium"}])) }
  end

  defp render_block(%Block.Ruler{lnb: lnb, type: "*", attrs: attrs}, context) do
    { context, build_ast(context, "hr", Enum.concat(normalise_attrs(context, attrs), [{"class", "thick"}])) }
  end

  ###########
  # Heading #
  ###########

  defp render_block(%Block.Heading{lnb: lnb, level: level, content: content, attrs: attrs}, context) do
    converted = convert(content, lnb, context)
    { converted, build_ast(converted, "h#{level}", normalise_attrs(converted, attrs), converted.value) }
  end

  ##############
  # Blockquote #
  ##############

  defp render_block(%Block.BlockQuote{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
    body = render_ast(blocks, context)
    { context, build_ast(context, "blockquote", normalise_attrs(context, attrs), body) }
  end

  #########
  # Table #
  #########

  defp render_block(%Block.Table{lnb: lnb, header: header, rows: rows, alignments: aligns, attrs: attrs}, context) do
    cols = for _align <- aligns, do: build_ast(context, "col", [], [])
    context1 = set_value(context, [build_ast(context, "colgroup", [], cols)])

    context2 = if header do
      header_rows = add_table_rows(context, [header], "th", aligns, lnb)
      header = build_ast(context, "thead", [], header_rows.value)

      append(add_messages_from(context1, header_rows), [header])
    else
      context1
    end

    table_rows = add_table_rows(context, rows, "td", aligns, lnb)
    context3 = append(add_messages_from(context2, table_rows), table_rows.value)

    { context3, build_ast(context, "table", normalise_attrs(context, attrs), List.flatten(context3.value)) }
  end

  ########
  # Code #
  ########

  defp render_block(%Block.Code{lnb: lnb, language: language, attrs: attrs} = block, context = %Context{options: options}) do
    class = if language, do: [{"class", code_classes(language, options.code_class_prefix)}], else: []
    lines = options.render_code.(block)
    { context, build_ast(context, "pre", normalise_attrs(context, attrs), [
      build_ast(context, "code", normalise_attrs(context, class), lines)
    ]) }
  end

  #########
  # Lists #
  #########

  defp render_block(%Block.List{lnb: lnb, type: type, blocks: items, attrs: attrs, start: start}, context) do
    content = render_ast(items, context)
    { context, build_ast(context, "#{type}", Enum.concat(normalise_attrs(context, attrs), list_start_to_attrs(start)), content) }
  end

  # format a single paragraph list item, and remove the para tags
  defp render_block(%Block.ListItem{lnb: lnb, blocks: blocks, spaced: false, attrs: attrs}, context)
  when length(blocks) == 1 do
    content = case render_ast(blocks, context) do
      [{ "p", _, text }] -> text
      content -> content
    end

    { context, build_ast(context, "li", normalise_attrs(context, attrs), content) }
  end

  # format a spaced list item
  defp render_block(%Block.ListItem{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
    content = render_ast(blocks, context)
    { context, build_ast(context, "li", normalise_attrs(context, attrs), content) }
  end


  # ##################
  # # Footnote Block #
  # ##################

  defp render_block(%Block.FnList{blocks: footnotes}, context) do
    items = Enum.map(footnotes, fn(note) ->
      blocks = append_footnote_link(note)
      %Block.ListItem{attrs: "#fn:#{note.number}", type: :ol, blocks: blocks}
    end)

    { context1, ast } = render_block(%Block.List{type: :ol, blocks: items}, context)
    { context1, build_ast(context, "div", [{"class", "footnotes"}], [build_ast(context, "hr", [], []), ast]) }
  end


  # #######################################
  # # Isolated IALs are rendered as paras #
  # #######################################

  defp render_block(%Block.Ial{verbatim: verbatim}, context) do
    { context, build_ast(context, "p", [], "{:#{verbatim}}") }
  end


  # ####################
  # # IDDef is ignored #
  # ####################

  defp render_block(%Block.IdDef{}, context), do: { context, nil }


  # ###########
  # # Plugins #
  # ###########

  # defp render_block(%Block.Plugin{lines: lines, handler: handler}, _context) do
  #   case handler.as_html(lines) do
  #     html when is_list(html) -> html
  #     {html, errors}          -> emit_messages(html, errors)
  #     html                    -> [html]
  #   end
  # end

  #####################################
  # And here are the inline renderers #
  #####################################{}

  defp render_block(%Inline.FnLink{ ref: ref, back_ref: back_ref, number: number, title: title, class_list: class_list }, context) do
    attributes = %{
      "href" => "##{ref}",
      "id" => back_ref,
      "class" => class_list,
      "title" => title
    }

    build_ast(context, "a", normalise_attrs(context, attributes), number)
  end

  defp render_block(%Inline.Codespan{ content: content, ial: ial }, context) do
    build_ast(context, "code", [{ "class", ["inline"] }], content, ial)
  end

  defp render_block(%Inline.Em{ content: content }, context) do
    build_ast(context, "em", [], content)
  end

  defp render_block(%Inline.Strong{ content: content }, context) do
    build_ast(context, "strong", [], content)
  end

  defp render_block(%Inline.Link{ href: url, text: text, title: nil, ial: ial }, context) do
    build_ast(context, "a", [{"href", url}], text, ial)
  end

  defp render_block(%Inline.Link{ href: url, text: text, title: title, ial: ial }, context) do
    build_ast(context, "a", [{"href", url}, {"title", title}], text, ial)
  end

  defp render_block(%Inline.Image{ href: path, alt: alt, title: nil, ial: ial }, context) do
    build_ast(context, "img", [{"src", path}, {"alt", alt}], nil, ial)
  end

  defp render_block(%Inline.Image{ href: path, alt: alt, title: title, ial: ial }, context) do
    build_ast(context, "img", [{"src", path}, {"alt", alt}, {"title", title}], nil, ial)
  end

  defp render_block(%Inline.Br{}, context) do
    build_ast(context, "br")
  end

  defp render_block(text, _context) when is_binary(text), do: text

  # def br,                  do: build_ast(context, "br")
  # def strikethrough(text), do: build_ast(context, "del", [], text)

  # def link(url, text),        do: build_ast("a", [{"href", url}], text)
  # def link(url, text, nil),   do: build_ast("a", [{"href", url}], text)
  # def link(url, text, title), do: build_ast("a", [{"href", url}, {"title", title}], text)

  # def image(path, alt, nil) do
  #   build_ast("img", [{"src", path}, {"alt", alt}])
  # end

  # def image(path, alt, title) do
  #   build_ast("img", [{"src", path}, {"alt", alt}, {"title", title}])
  # end

  # Table rows
  defp add_table_rows(context, rows, tag, aligns, lnb) do
    numbered_rows = rows
                    |> Enum.zip(Stream.iterate(lnb, &(&1 + 1)))

    context1 =
      numbered_rows
      |> Enum.reduce(context, fn {row, lnb}, ctx ->
        tds_ctx = add_tds(context, row, tag, aligns, lnb)
        prepend(add_messages_from(ctx, tds_ctx), build_ast(ctx, "tr", [], Enum.reverse(tds_ctx.value)))
      end)

    %{ context1 | value: Enum.reverse(context1.value) }
  end

  defp add_tds(context, row, tag, aligns, lnb) do
    Enum.reduce(1..length(row), context, add_td_fn(row, tag, aligns, lnb))
  end

  defp add_td_fn(row, tag, aligns, lnb) do
    fn n, ctx ->
      style =
      case Enum.at(aligns, n - 1, :default) do
        :default -> ""
        align    -> {"style", "text-align: #{align}"}
      end
      col = Enum.at(row, n - 1)
      converted = convert(col, lnb,  ctx)
      prepend(add_messages_from(ctx, converted), build_ast(converted, tag, [style], converted.value))
    end
  end

  ###############################
  # Output generating functions #
  ###############################

  defp build_ast(context, tag, attrs \\ [], content \\ nil, ial \\ nil)
  defp build_ast(_context, tag, attrs, content, nil) do
    { tag, attrs, normalise_content(content) }
  end
  defp build_ast(_context, tag, attrs, content, []) do
    { tag, attrs, normalise_content(content) }
  end
  defp build_ast(context, tag, attrs, content, ial) do
    attrs = append_ial_attributes(context, attrs, ial)
    { tag, attrs, normalise_content(content) }
  end

  defp normalise_attrs(context, attrs, lnb \\ nil)
  defp normalise_attrs(_, nil, _), do: []
  defp normalise_attrs(_, attrs, _) when is_list(attrs), do: attrs
  defp normalise_attrs(context, attrs, lnb) when is_binary(attrs) do
    { context1, attrs } = parse_attrs(context, attrs, lnb)
    normalise_attrs(context1, attrs)
  end

  defp normalise_attrs(_, attrs = %{}, _) do
    attrs
    |> Enum.filter(fn { _, v } -> v != nil end)
    |> Enum.map(fn
      { k, v } when is_list(v) -> { k, Enum.join(v, " ") }
      { k, v } -> { k, v }
    end)
  end

  defp append_ial_attributes(_, attrs, nil), do: attrs
  defp append_ial_attributes(context, attrs, ial) do
    merged =
      context
      |> normalise_attrs(attrs)
      |> Enum.into(%{})
      |> Map.merge(ial, fn _k, v1, v2 -> v1 ++ v2 end)

    normalise_attrs(context, merged)
    # normalised =
    #   context
    #   |> normalise_attrs(ial)

    # Enum.concat(attrs, normalised)
  end

  defp normalise_content(content \\ nil)
  defp normalise_content(nil), do: []
  defp normalise_content(content) when is_integer(content), do: [Integer.to_string(content)]
  defp normalise_content(content) when is_list(content), do: content
  defp normalise_content(content) when is_binary(content), do: [content]
  defp normalise_content(content), do: content

  defp list_start_to_attrs(""), do: []
  defp list_start_to_attrs(start) do
    case Regex.run(~r{start="(\d+)"}, ~s{#{start}}) do
      nil -> []
      [_, start] -> [{"start", start}]
    end
  end

  ###################
  # Other functions #
  ###################

  def replace_hard_line_break(text, pattern) do
    case Regex.match?(pattern, text) do
      true ->
        [["br", [], []], Regex.replace(pattern, text, "")]

      false ->
        text
    end
  end

  defp code_classes(language, prefix) do
    ["" | String.split( prefix || "" )]
    |> Enum.map( fn pfx -> "#{pfx}#{language}" end )
    |> Enum.join(" ")
  end

  defp clean_inline_chunk([ast]) when is_tuple(ast), do: ast
  defp clean_inline_chunk(chunk = [head|_]) when is_binary(head) do
    Enum.join(chunk)
  end

  ###############################
  # Append Footnote Return Link #
  ###############################

  def append_footnote_link(note=%Block.FnDef{}) do
    fnlink = %Inline.FnLink{ ref: "fnref:#{note.number}", title: "return to article", number: "&#x21A9;" }
    fnlink = %{ fnlink | class_list: ["reversefootnote"] }
    [ last_block | blocks ] = Enum.reverse(note.blocks)
    last_block = append_footnote_link(last_block, fnlink)
    [last_block | blocks]
    |> List.flatten
  end

  def append_footnote_link(block=%Block.Para{lines: [last_line|lines]}, fnlink) do
    # Escape the ampersand. Floki will convert it to a space otherwise
    last_line = "#{last_line}&amp;nbsp;"
    [put_in(block.lines, [fnlink | Enum.reverse([last_line | lines])])]
  end

  def append_footnote_link(block, fnlink) do
    [block, %Block.Para{lines: fnlink}]
  end

  def render_code(%Block.Code{lines: lines}) do
    lines |> Enum.join("\n") |> escape(true)
  end

  defp code_classes(language, prefix) do
    ["" | String.split( prefix || "" )]
    |> Enum.map( fn pfx -> "#{pfx}#{language}" end )
    |> Enum.join(" ")
  end
end

# SPDX-License-Identifier: Apache-2.0
