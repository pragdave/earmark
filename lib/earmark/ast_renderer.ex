defmodule Earmark.AstRenderer do
  alias Earmark.Block
  alias Earmark.Context
  alias Earmark.Options
  import Earmark.Ast.Inline, only: [convert: 3]
  import Earmark.Helpers, only: [escape: 2]
  import Earmark.Helpers.AstHelpers
  import Earmark.Message, only: [add_messages_from: 2, add_messages: 2, get_messages: 1]
  import Earmark.Context, only: [append: 2, set_value: 2]
  import Earmark.Options, only: [get_mapper: 1]

  @doc false
  def render(blocks), do: render(blocks, Context.update_context)
  def render(blocks, context = %Context{options: %Options{}}) do
    messages = get_messages(context)
    IO.inspect {1000, blocks}

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
    IO.inspect {1050, attrs}
    ast   = { "p", add_attrs(attrs), context1.value |> Enum.reverse}
    {context1, ast}
  end

  ########
  # Html #
  ########
  defp render_block(%Block.Html{html: html}, context) do
    {context, Enum.intersperse(html, ?\n)}
  end

  defp render_block(%Block.HtmlOther{html: html}, context) do
    {context, Enum.intersperse(html, ?\n)}
  end

  #########
  # Ruler #
  #########
  defp render_block(%Block.Ruler{lnb: lnb, type: "-", attrs: attrs}, context) do
    add_attrs(context, "<hr/>\n", attrs, [{"class", ["thin"]}], lnb)
  end

  defp render_block(%Block.Ruler{lnb: lnb, type: "_", attrs: attrs}, context) do
    add_attrs(context, "<hr/>\n", attrs, [{"class", ["medium"]}], lnb)
  end

  defp render_block(%Block.Ruler{lnb: lnb, type: "*", attrs: attrs}, context) do
    add_attrs(context, "<hr/>\n", attrs, [{"class", ["thick"]}], lnb)
  end

  ###########
  # Heading #
  ###########
  defp render_block(
         %Block.Heading{lnb: lnb, level: level, content: content, attrs: attrs},
         context
       ) do
    context1 = convert(content, lnb, context)
    ast = { "h#{level}", add_attrs(attrs), context1.value |> Enum.reverse }
    # add_attrs(children, ast, attrs, [], lnb)
    {context1, ast}
  end

  ##############
  # Blockquote #
  ##############

  defp render_block(%Block.BlockQuote{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
    {context1, ast} = render(blocks, context)
    {context1, {"blockquote", add_attrs(attrs), ast}}
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
    cols = for _align <- aligns, do: "<col>\n"
    {context1, html} = add_attrs(context, "<table>\n", attrs, [], lnb)
    html = [html, "<colgroup>\n", cols, "</colgroup>\n"]
    context2 = set_value(context1, html)

    context3 =
      if header do
        append(add_trs(append(context2, "<thead>\n"), [header], "th", aligns, lnb), "</thead>\n")
      else
        # Maybe an error, needed append(context, html)
        context2
      end

    context4 = add_trs(context3, rows, "td", aligns, lnb)

    {context4, [context4.value, "</table>\n"]}
  end

  ########
  # Code #
  ########

  defp render_block(
         %Block.Code{lnb: lnb, language: language, attrs: attrs} = block,
         context = %Context{options: options}
       ) do
    classes =
      if language, do: [code_classes(language, options.code_class_prefix)], else: [] 

    lines = render_code(block)
    # add_attrs(context, html, attrs, [], lnb)
    ast = { "pre", [], [{"code", classes, [lines]}] }
    {context, ast}
  end

  #########
  # Lists #
  #########

  defp render_block(
         %Block.List{lnb: lnb, type: type, blocks: items, attrs: attrs, start: start},
         context
       ) do
    {context1, ast} = render(items, context)
    # html = "<#{type}#{start}>\n#{content}</#{type}>\n"
    # add_attrs(context1, html, attrs, [], lnb)
    {context1, {to_string(type), add_attrs(attrs), ast}}
  end

  # format a single paragraph list item, and remove the para tags
  defp render_block(
         %Block.ListItem{lnb: lnb, blocks: blocks, spaced: false, attrs: attrs},
         context
       )
       when length(blocks) == 1 do
    {context1, [{"p", _, ast}]} = render(blocks, context)
#    IO.inspect ast
    # content = Regex.replace(~r{</?p>}, content, "")
    # html = "<li>#{content}</li>\n"
    # add_attrs(context1, html, attrs, [], lnb)
    {context1, {"li", add_attrs(attrs), ast}}
  end

  # format a spaced list item
  defp render_block(%Block.ListItem{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
#    IO.inspect {1200, blocks, attrs}
    {context1, ast} = render(blocks, context)
#    IO.inspect {1201, ast, attrs}
    {context1, {"li", add_attrs(attrs), ast}}
  end

  ##################
  # Footnote Block #
  ##################

  defp render_block(%Block.FnList{blocks: footnotes}, context) do
#    IO.inspect {1100, footnotes}
    items =
      Enum.map(footnotes, fn note ->
        blocks = append_footnote_link(note)
        IO.inspect {1050, blocks}
        %Block.ListItem{attrs: %{id: ["#fn:#{note.number}"]}, type: :ol, blocks: blocks}
      end)

    {context1, ast} = render_block(%Block.List{type: :ol, blocks: items}, context)
    {context1, { "div", [{"class", "footnotes"}],
      [{"hr", [], []} | ast] }}
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
    IO.inspect {1300, note}
    # fnlink =
    #   # ~s[<a href="#fnref:#{note.number}" title="return to article" class="reversefootnote">&#x21A9;</a>]
    #   "[&#x21a9;](#fnref:#{note.number})]\n{:title='return to article' .reversefootnote}"

    IO.inspect {1320, note.blocks}
    [last_block | blocks] = Enum.reverse(note.blocks)
    # last_block = append_footnote_link(last_block, fnlink)

    attrs = %{title: "return to article", class: "reversefootnote", href: "#fnref:#{note.number}"}
    [%{last_block|attrs: attrs} | blocks]
      |> Enum.reverse
      |> List.flatten
  end
  defp append_footnote_link(block = %Block.Para{lines: lines}, fnlink) do
    IO.inspect {1301, lines, fnlink}
    [last_line | lines] = Enum.reverse(lines)
    last_line = "#{last_line}&nbsp;#{fnlink}"
    [put_in(block.lines, Enum.reverse([last_line | lines]))]
  end
  defp append_footnote_link(block, fnlink) do
    IO.inspect {1302, block, fnlink}
    [block, %Block.Para{lines: fnlink}]
  end

end

# SPDX-License-Identifier: Apache-2.0

