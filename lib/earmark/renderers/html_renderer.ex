defmodule Earmark.Renderers.HtmlRenderer do

  alias  Earmark.Block
  alias  Earmark.Context
  alias  Earmark.Options
  alias Earmark.Inline
  import Earmark.Inline,  only: [ convert: 3 ]
  import Earmark.Helpers, only: [ escape: 2, replace: 3 ]
  import Earmark.Helpers.HtmlHelpers
  import Earmark.Message, only: [ add_messages_from: 2, add_messages: 2, get_messages: 1 ]
  import Earmark.Context, only: [ append: 2, set_value: 2 ]

  def render(blocks, context=%Context{options: %Options{mapper: mapper}}) do
    messages = get_messages(context)

    {contexts, html} =
    mapper.(blocks, &(render_block(&1, put_in(context.options.messages, [])))) |> Enum.unzip()

    all_messages = 
      contexts 
      |> Enum.reduce( messages, fn (ctx, messages1) ->  messages1 ++ get_messages(ctx) end) 

    {put_in(context.options.messages, all_messages), html |> IO.iodata_to_binary()}
  end

  def render_inline(blocks, context=%Context{options: %Options{mapper: mapper}}) do
    result = blocks
    |> mapper.(&(render_block(&1, context)))
    |> Enum.reverse()
    |> Enum.join
  end

  #############
  # Paragraph #
  #############
  defp render_block(%Block.Para{lnb: lnb, lines: lines, attrs: attrs}, context) do
    lines = convert(lines, lnb, context)
    add_attrs!(lines, "<p>#{lines.value}</p>\n", attrs, [], lnb)
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
    add_attrs!(context, "<hr/>\n", attrs, [{"class", ["thin"]}], lnb)
  end

  defp render_block(%Block.Ruler{lnb: lnb, type: "_", attrs: attrs}, context) do
    add_attrs!(context, "<hr/>\n", attrs, [{"class", ["medium"]}], lnb)
  end

  defp render_block(%Block.Ruler{lnb: lnb, type: "*", attrs: attrs}, context) do
    add_attrs!(context, "<hr/>\n", attrs, [{"class", ["thick"]}], lnb)
  end

  ###########
  # Heading #
  ###########
  defp render_block(%Block.Heading{lnb: lnb, level: level, content: content, attrs: attrs}, context) do
    converted = convert(content, lnb, context)
    html = "<h#{level}>#{converted.value}</h#{level}>\n"
    add_attrs!(converted, html, attrs, [], lnb)
  end

  ##############
  # Blockquote #
  ##############

  defp render_block(%Block.BlockQuote{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
    {context1, body} = render(blocks, context)
    html = "<blockquote>#{body}</blockquote>\n"
    add_attrs!(context1, html, attrs, [], lnb)
  end

  #########
  # Table #
  #########

  defp render_block(%Block.Table{lnb: lnb, header: header, rows: rows, alignments: aligns, attrs: attrs}, context) do
    cols = for _align <- aligns, do: "<col>\n"
    {context1, html} = add_attrs!(context, "<table>\n", attrs, [], lnb)
    html = [ html , "<colgroup>\n", cols, "</colgroup>\n" ]
    context2 = set_value( context1, html )

    context3 = if header do
      append( add_trs(append(context2, "<thead>\n"), [header], "th", aligns, lnb), "</thead>\n" )
    else
      # Maybe an error, needed append(context, html)
      context2
    end

    context4 =  add_trs(context3, rows, "td", aligns, lnb)
    
    {context4, [ context4.value, "</table>\n" ]}
  end

  ########
  # Code #
  ########

  defp render_block(%Block.Code{lnb: lnb, language: language, attrs: attrs} = block, context = %Context{options: options}) do
    class = if language, do: ~s{ class="#{code_classes( language, options.code_class_prefix)}"}, else: ""
    tag = ~s[<pre><code#{class}>]
    lines = options.render_code.(block)
    html = ~s[#{tag}#{lines}</code></pre>\n]
    add_attrs!(context, html, attrs, [], lnb)
  end

  #########
  # Lists #
  #########

  defp render_block(%Block.List{lnb: lnb, type: type, blocks: items, attrs: attrs, start: start}, context) do
    {context1, content} = render(items, context)
    html = "<#{type}#{start}>\n#{content}</#{type}>\n"
    add_attrs!(context1, html, attrs, [], lnb)
  end

  # format a single paragraph list item, and remove the para tags
  defp render_block(%Block.ListItem{lnb: lnb, blocks: blocks, spaced: false, attrs: attrs}, context)
  when length(blocks) == 1 do
    {context1, content} = render(blocks, context)
    content = Regex.replace(~r{</?p>}, content, "")
    html = "<li>#{content}</li>\n"
    add_attrs!(context1, html, attrs, [], lnb)
  end

  # format a spaced list item
  defp render_block(%Block.ListItem{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
    {context1, content} = render(blocks, context)
    html = "<li>#{content}</li>\n"
    add_attrs!(context1, html, attrs, [], lnb)
  end

  ##################
  # Footnote Block #
  ##################

  defp render_block(%Block.FnList{blocks: footnotes}, context) do
    items = Enum.map(footnotes, fn(note) ->
      blocks = append_footnote_link(note)
      %Block.ListItem{attrs: "#fn:#{note.number}", type: :ol, blocks: blocks}
    end)
    {context1, html} = render_block(%Block.List{type: :ol, blocks: items}, context)
    {context1, Enum.join([~s[<div class="footnotes">], "<hr>", html, "</div>"], "\n")}
  end

  #######################################
  # Isolated IALs are rendered as paras #
  #######################################

  defp render_block(%Block.Ial{verbatim: verbatim}, context) do
    {context, "<p>{:#{verbatim}}</p>\n"}
  end

  ####################
  # IDDef is ignored #
  ####################

  defp render_block(%Block.IdDef{}, context), do: {context, ""}

  ###########
  # Plugins #
  ###########

  defp render_block(%Block.Plugin{lines: lines, handler: handler}, context) do
    case handler.as_html(lines) do
      html when is_list(html) -> {context, html}
      {html, errors}          -> {add_messages(context, errors), html}
      html                    -> {context, [html]}
    end
  end

  #####################################
  # And here are the inline renderers #
  #####################################

  defp render_block(%Inline.Br{}, _), do: "<br/>"
  defp render_block(%Inline.Codespan{ content: text, ial: ial }, context) do
    {_, html} = add_attrs!(context, ~s[<code>#{text}</code>], ial, [{ "class", ["inline"] }], nil)
    html
  end
  defp render_block(%Inline.Em{ content: text }, _), do: "<em>#{text}</em>"
  defp render_block(%Inline.Strong{ content: text }, _), do: "<strong>#{text}</strong>"
  defp render_block(%Inline.Strikethrough{ content: text }, _), do: "<del>#{text}</del>"

  defp render_block(%Inline.Link{ href: url, text: text, title: nil, ial: ial }, context) do
    {_, html} = add_attrs!(context, ~s[<a href="#{url}">#{text}</a>], ial, [], nil)
    html
  end

  defp render_block(%Inline.Link{ href: url, text: text, title: title, ial: ial }, context) do
    {_, html} = add_attrs!(context, ~s[<a href="#{url}" title="#{title}">#{text}</a>], ial, [], nil)
    html
  end

  defp render_block(%Inline.Image{ href: path, alt: alt, title: nil, ial: ial }, context) do
    {_, html} = add_attrs!(context, ~s[<img src="#{path}" alt="#{alt}"/>], ial, [], nil)
    html
  end

  defp render_block(%Inline.Image{ href: path, alt: alt, title: title, ial: ial }, context) do
    {_, html} = add_attrs!(context, ~s[<img src="#{path}" alt="#{alt}" title="#{title}"/>], ial, [], nil)
    html
  end

  defp render_block(%Inline.FnLink{ ref: ref, back_ref: back_ref, number: number, title: title, class_list: class_list }, context) do
    ~s[<a href="##{ref}" id="#{back_ref}" class="footnote" title="see footnote">#{number}</a>]
  end

  defp render_block(text, _context) when is_binary(text), do: text

  # Table rows
  def add_trs(context, rows, tag, aligns, lnb) do
    numbered_rows = rows
                    |> Enum.zip(Stream.iterate(lnb, &(&1 + 1)))
    # for {row, lnb1} <- numbered_rows, do: "<tr>\n#{add_tds(context, row, tag, aligns, lnb1)}\n</tr>\n"
    numbered_rows
      |> Enum.reduce(context, fn {row, lnb}, ctx ->
       append( add_tds(append(ctx, "<tr>\n"), row, tag, aligns, lnb), "\n</tr>\n" )
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
        align    -> " style=\"text-align: #{align}\""
      end
      col = Enum.at(row, n - 1)
      converted = convert(col, lnb,  ctx)
      append(add_messages_from(ctx, converted), "<#{tag}#{style}>#{converted.value}</#{tag}>")
    end
  end

  defp append_ial_attributes(tag, ial) do
    
  end


  ###############################
  # Append Footnote Return Link #
  ###############################

  def append_footnote_link(note=%Block.FnDef{}) do
    fnlink = ~s[<a href="#fnref:#{note.number}" title="return to article" class="reversefootnote">&#x21A9;</a>]
    [ last_block | blocks ] = Enum.reverse(note.blocks)
    last_block = append_footnote_link(last_block, fnlink)
    Enum.reverse([last_block | blocks])
    |> List.flatten
  end

  def append_footnote_link(block=%Block.Para{lines: lines}, fnlink) do
    [ last_line | lines ] = Enum.reverse(lines)
    last_line = "#{last_line}&nbsp;#{fnlink}"
    [put_in(block.lines, Enum.reverse([last_line | lines]))]
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

  ###########################################
  # Other functions specific to each parser #
  ###########################################

  def replace_hard_line_break(text, pattern) do
    Regex.replace(pattern, text, "<br/>" <> "\n")
  end

  def clean_inline(value) do
    value
    |> Enum.reverse()
    |> IO.iodata_to_binary
    |> replace(~r{(</[^>]*>)‘}, "\\1’")
    |> replace(~r{(</[^>]*>)“}, "\\1”")
  end

end

# SPDX-License-Identifier: Apache-2.0
