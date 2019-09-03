defmodule Earmark.AstRenderer do
  alias Earmark.Block
  alias Earmark.Context
  alias Earmark.Options
  import Earmark.Ast.Inline, only: [convert: 3]
  import Earmark.Helpers.AstHelpers
  import Earmark.Ast.Renderer.FootnoteListRenderer
  import Earmark.Ast.Renderer.HtmlRenderer
  import Earmark.Ast.Renderer.TableRenderer
  import Earmark.Message, only: [add_messages_from: 2, get_messages: 1]
  import Earmark.Context, only: [append: 2]
  import Earmark.Options, only: [get_mapper: 1]

  @doc false
  def render(blocks), do: render(blocks, Context.update_context)
  def render(blocks, context = %Context{options: %Options{}}) do
    messages = get_messages(context)

    {contexts, ast} =
      get_mapper(context.options).(
        blocks,
        &render_block(&1, put_in(context.options.messages, []))
      )
      |> Enum.unzip()

    all_messages =
      contexts
      |> Enum.reduce(messages, fn ctx, messages1 -> messages1 ++ get_messages(ctx) end)

    {put_in(context.options.messages, all_messages), ast}
  end

  #############
  # Paragraph #
  #############
  defp render_block(%Block.Para{lnb: lnb, lines: lines, attrs: attrs}, context) do
    context1 = convert(lines, lnb, context)
    ast   = { "p", merge_attrs(attrs), context1.value |> Enum.reverse}
    {context1, ast}
  end

  ########
  # Html #
  ########
  defp render_block(%Block.Html{html: html}, context) do
    {context, render_html_block(html)}
  end

  defp render_block(%Block.HtmlOneline{html: html}, context) do
    {context, render_html_oneline(html)}
  end

  defp render_block(%Block.HtmlComment{lines: lines}, context) do
    lines1 =
      lines |> Enum.map(&render_html_comment_line/1)
    {context, {:comment, [], lines1}}
  end

  #########
  # Ruler #
  #########
  defp render_block(%Block.Ruler{type: "-", attrs: attrs}, context) do
    {context, {"hr", merge_attrs(attrs, %{"class" => "thin"}), []}}
  end
  defp render_block(%Block.Ruler{type: "_", attrs: attrs}, context) do
    {context, {"hr", merge_attrs( attrs, %{"class" => "medium"}), []}}
  end
  defp render_block(%Block.Ruler{type: "*", attrs: attrs}, context) do
    {context, {"hr", merge_attrs(attrs, %{"class" => "thick"}), []}}
  end

  ###########
  # Heading #
  ###########
  defp render_block(
         %Block.Heading{lnb: lnb, level: level, content: content, attrs: attrs},
         context
       ) do
    context1 = convert(content, lnb, context)
    ast = { "h#{level}", merge_attrs(attrs), context1.value |> Enum.reverse }
    # merge_attrs(children, ast, attrs, [], lnb)
    {context1, ast}
  end

  ##############
  # Blockquote #
  ##############

  defp render_block(%Block.BlockQuote{blocks: blocks, attrs: attrs}, context) do
    {context1, ast} = render(blocks, context)
    {context1, {"blockquote", merge_attrs(attrs), ast}}
    # html = "<blockquote>#{body}</blockquote>\n"
    # add_attrs(context1, html, attrs, [], lnb)
  end

  #########
  # Table #
  #########

  defp render_block(
         %Block.Table{lnb: lnb, header: header, rows: rows, alignments: aligns, attrs: attrs},
         context
       ) do
    {rows_ast, context1} = render_rows(rows, lnb, aligns, context)

    {rows_ast1, context2} =
      if header do
        {header_ast, context3} = render_header(header, lnb, aligns, context1)
        {[header_ast|rows_ast], context3}
      else
        {rows_ast, context1}
      end

    {context2, {"table", merge_attrs(attrs), rows_ast1}}
  end

  ########
  # Code #
  ########

  defp render_block(
         %Block.Code{language: language, attrs: attrs} = block,
         context = %Context{options: options}
       ) do
    classes =
      if language, do: [code_classes(language, options.code_class_prefix)], else: []

    lines = render_code(block)
    ast = { "pre", merge_attrs(attrs), [{"code", classes, [lines]}] }
    {context, ast}
  end

  #########
  # Lists #
  #########

  @start_rgx ~r{\d+}
  defp render_block(
         %Block.List{type: type, blocks: items, attrs: attrs, start: start},
         context
       ) do
    {context1, ast} = render(items, context)
    start_map = case start && Regex.run(@start_rgx, start) do
      [start1] -> %{start: start1}
      _        -> %{}
    end
    # html = "<#{type}#{start}>\n#{content}</#{type}>\n"
    # add_attrs(context1, html, attrs, [], lnb)
    {context1, {to_string(type), merge_attrs(attrs, start_map), ast}}
  end

  # format a single paragraph list item, and remove the para tags
  defp render_block(
         %Block.ListItem{blocks: blocks, spaced: false, attrs: attrs},
         context
       )
       when length(blocks) == 1 do
    {context1, [{"p", _, ast}]} = render(blocks, context)
    {context1, {"li", merge_attrs(attrs), ast}}
  end

  # format a spaced list item
  defp render_block(%Block.ListItem{blocks: blocks, attrs: attrs}, context) do
    {context1, ast} = render(blocks, context)
    {context1, {"li", merge_attrs(attrs), ast}}
  end

  ##################
  # Footnote Block #
  ##################

  defp render_block(%Block.FnList{blocks: footnotes}, context) do
    items =
      Enum.map(footnotes, fn note ->
        blocks = append_footnote_link(note)
        %Block.ListItem{attrs: %{id: ["#fn:#{note.number}"]}, type: :ol, blocks: blocks}
      end)

    {context, render_footnote_list(items)}
  end

  #######################################
  # Isolated IALs are rendered as paras #
  #######################################

  defp render_block(%Block.Ial{verbatim: verbatim}, context) do
    {context,
     {"p", [], ["{:#{verbatim}}"]}}
  end

  ####################
  # IDDef is ignored #
  ####################

  defp render_block(%Block.IdDef{}, context), do: {context, ""}

  #####################################
  # And here are the inline renderers #
  #####################################

  def br, do: "<br>"
  def em(text), do: {"em", [], text}
  def strikethrough(text), do: "<del>#{text}</del>"

  def image(path, alt, nil) do
    ~s[<img src="#{path}" alt="#{alt}"/>]
  end

  def image(path, alt, title) do
    ~s[<img src="#{path}" alt="#{alt}" title="#{title}"/>]
  end

  # Table rows
  def add_trs(context, rows, tag, aligns, lnb) do
    numbered_rows =
      rows
      |> Enum.zip(Stream.iterate(lnb, &(&1 + 1)))

    # for {row, lnb1} <- numbered_rows, do: "<tr>\n#{add_tds(context, row, tag, aligns, lnb1)}\n</tr>\n"
    numbered_rows
    |> Enum.reduce(context, fn {row, lnb}, ctx ->
      append(add_tds(append(ctx, "<tr>\n"), row, tag, aligns, lnb), "\n</tr>\n")
    end)
  end

  defp add_tds(context, row, tag, aligns, lnb) do
    Enum.reduce(1..length(row), context, add_td_fn(row, tag, aligns, lnb))
  end

  defp add_td_fn(row, tag, aligns, lnb) do
    fn n, ctx ->
      style =
        case Enum.at(aligns, n - 1, :default) do
          :default -> ""
          align -> " style=\"text-align: #{align}\""
        end

      col = Enum.at(row, n - 1)
      converted = convert(col, lnb, ctx)
      append(add_messages_from(ctx, converted), "<#{tag}#{style}>#{converted.value}</#{tag}>")
    end
  end

  ###############################
  # Append Footnote Return Link #
  ###############################

  defp append_footnote_link(note)
  defp append_footnote_link(note = %Block.FnDef{}) do
    [last_block | blocks] = Enum.reverse(note.blocks)

    attrs = %{title: "return to article", class: "reversefootnote", href: "#fnref:#{note.number}"}
    [%{last_block|attrs: attrs} | blocks]
      |> Enum.reverse
      |> List.flatten
  end

end

# SPDX-License-Identifier: Apache-2.0
