defmodule Earmark.AstRenderer do

  alias Earmark.Block
  alias Earmark.Context
  alias Earmark.Options

  import Earmark.Inline, only: [convert: 3]
  import Earmark.Message, only: [add_messages_from: 2, add_messages: 2, get_messages: 1]
  import Earmark.Options, only: [get_mapper: 1]

  @moduledoc """
  Renders the parsed markdown document in a format compatible with
  Floki's output (v0.21.0)
  """

  @doc false
  def render(blocks, context) do
    messages = get_messages(context)

    {contexts, ast} =
      get_mapper(context.options).(
        blocks,
        &render_block_as_ast(&1, put_in(context.options.messages, []))
      )
      |> Enum.unzip()

    all_messages =
      contexts
      |> Enum.reduce(messages, fn ctx, messages1 -> messages1 ++ get_messages(ctx) end)

    {put_in(context.options.messages, all_messages), ast}
  end
  
  defp render_block_as_ast(%Block.Para{lnb: lnb, lines: lines, attrs: attrs}, context) do
    lines = convert(lines, lnb, context)
    add_attrs!(lines, "<p>#{lines.value}</p>\n", attrs, [], lnb)
  end

  ########
  # Html #
  ########
  defp render_block_as_ast(%Block.Html{html: html}, context) do
    {context, Enum.intersperse(html, ?\n)}
  end

  defp render_block_as_ast(%Block.HtmlOther{html: html}, context) do
    {context, Enum.intersperse(html, ?\n)}
  end

  #########
  # Ruler #
  #########
  defp render_block_as_ast(%Block.Ruler{lnb: lnb, type: "-", attrs: attrs}, context) do
    add_attrs!(context, "<hr/>\n", attrs, [{"class", ["thin"]}], lnb)
  end

  defp render_block_as_ast(%Block.Ruler{lnb: lnb, type: "_", attrs: attrs}, context) do
    add_attrs!(context, "<hr/>\n", attrs, [{"class", ["medium"]}], lnb)
  end

  defp render_block_as_ast(%Block.Ruler{lnb: lnb, type: "*", attrs: attrs}, context) do
    add_attrs!(context, "<hr/>\n", attrs, [{"class", ["thick"]}], lnb)
  end

  ###########
  # Heading #
  ###########
  defp render_block_as_ast(
         %Block.Heading{lnb: lnb, level: level, content: content, attrs: attrs},
         context
       ) do
    converted = convert(content, lnb, context)
    html = "<h#{level}>#{converted.value}</h#{level}>\n"
    add_attrs!(converted, html, attrs, [], lnb)
  end

  ##############
  # Blockquote #
  ##############

  defp render_block_as_ast(%Block.BlockQuote{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
    {context1, body} = render(blocks, context)
    html = "<blockquote>#{body}</blockquote>\n"
    add_attrs!(context1, html, attrs, [], lnb)
  end

  #########
  # Table #
  #########

  defp render_block_as_ast(
         %Block.Table{lnb: lnb, header: header, rows: rows, alignments: aligns, attrs: attrs},
         context
       ) do
    cols = for _align <- aligns, do: "<col>\n"
    {context1, html} = add_attrs!(context, "<table>\n", attrs, [], lnb)
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

  defp render_block_as_ast(
         %Block.Code{lnb: lnb, language: language, attrs: attrs} = block,
         context = %Context{options: options}
       ) do
    class =
      if language, do: ~s{ class="#{code_classes(language, options.code_class_prefix)}"}, else: ""

    tag = ~s[<pre><code#{class}>]
    lines = options.render_code.(block)
    html = ~s[#{tag}#{lines}</code></pre>\n]
    add_attrs!(context, html, attrs, [], lnb)
  end

  #########
  # Lists #
  #########

  defp render_block_as_ast(
         %Block.List{lnb: lnb, type: type, blocks: items, attrs: attrs, start: start},
         context
       ) do
    {context1, content} = render(items, context)
    html = "<#{type}#{start}>\n#{content}</#{type}>\n"
    add_attrs!(context1, html, attrs, [], lnb)
  end

  # format a single paragraph list item, and remove the para tags
  defp render_block_as_ast(
         %Block.ListItem{lnb: lnb, blocks: blocks, spaced: false, attrs: attrs},
         context
       )
       when length(blocks) == 1 do
    {context1, content} = render(blocks, context)
    content = Regex.replace(~r{</?p>}, content, "")
    html = "<li>#{content}</li>\n"
    add_attrs!(context1, html, attrs, [], lnb)
  end

  # format a spaced list item
  defp render_block_as_ast(%Block.ListItem{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
    {context1, content} = render(blocks, context)
    html = "<li>#{content}</li>\n"
    add_attrs!(context1, html, attrs, [], lnb)
  end

  ##################
  # Footnote Block #
  ##################

  defp render_block_as_ast(%Block.FnList{blocks: footnotes}, context) do
    items =
      Enum.map(footnotes, fn note ->
        blocks = append_footnote_link(note)
        %Block.ListItem{attrs: "#fn:#{note.number}", type: :ol, blocks: blocks}
      end)

    {context1, html} = render_block_as_ast(%Block.List{type: :ol, blocks: items}, context)
    {context1, Enum.join([~s[<div class="footnotes">], "<hr>", html, "</div>"], "\n")}
  end

  #######################################
  # Isolated IALs are rendered as paras #
  #######################################

  defp render_block_as_ast(%Block.Ial{verbatim: verbatim}, context) do
    {context, "<p>{:#{verbatim}}</p>\n"}
  end

  ####################
  # IDDef is ignored #
  ####################

  defp render_block_as_ast(%Block.IdDef{}, context), do: {context, ""}

  ###########
  # Plugins #
  ###########

  defp render_block_as_ast(%Block.Plugin{lines: lines, handler: handler}, context) do
    case handler.as_html(lines) do
      html when is_list(html) -> {context, html}
      {html, errors} -> {add_messages(context, errors), html}
      html -> {context, [html]}
    end
  end
end
