defmodule Earmark.ASTRenderer do

  alias  Earmark.Block
  alias  Earmark.Context
  alias  Earmark.Options
  import Earmark.Inline,  only: [ convert: 4 ]
  import Earmark.Helpers, only: [ escape: 2 ]
  import Earmark.Global.Messages
  import Earmark.Helpers.AttrParser

  def render(markdown, options) do
    start_link()
    { blocks, context } = Earmark.parse(markdown, %{ options | renderer: Earmark.ASTRenderer })
    ast = 
      render_ast(blocks, context) 
      |> Enum.reject(&is_nil/1)
      |> flatten_ast()

    case pop_all_messages() do
      []       -> {:ok, ast, []}
      messages -> {:error, ast, messages}
    end
  end

  def render_ast(blocks, context=%Context{options: %Options{mapper: mapper}}) do
    html =
      mapper.(blocks, &(render_block(&1, context)))
      # IO.inspect(html)
  end


  defp flatten_ast(ast) when length(ast) == 1 do 
    hd(ast)
  end
  
  defp flatten_ast(ast), do: List.flatten(ast)


  #############
  # Paragraph #
  #############
  defp render_block(%Block.Para{lnb: lnb, lines: lines, attrs: attrs}, context) do
    lines = 
      convert(lines, lnb, context, true)
      |> Enum.map(fn
           l = " " -> l
           l when is_binary(l) -> Floki.parse(l)
           l -> l
         end)
      |> List.flatten

    build_ast("p", normalise_attrs(attrs, lnb), lines)
  end


  ########
  # Html #
  ########
  defp render_block(%Block.Html{html: html}, _context) do
    Floki.parse(html)
  end

  defp render_block(%Block.HtmlOther{html: html}, _context) do
    Floki.parse(html)
  end

  #########
  # Ruler #
  #########
  defp render_block(%Block.Ruler{lnb: lnb, type: "-", attrs: attrs}, _context) do
    build_ast("hr", Enum.concat(normalise_attrs(attrs), [{"class", "thin"}]))
  end

  defp render_block(%Block.Ruler{lnb: lnb, type: "_", attrs: attrs}, _context) do
    build_ast("hr", Enum.concat(normalise_attrs(attrs), [{"class", "medium"}]))
  end

  defp render_block(%Block.Ruler{lnb: lnb, type: "*", attrs: attrs}, _context) do
    build_ast("hr", Enum.concat(normalise_attrs(attrs), [{"class", "thick"}]))
  end


  ###########
  # Heading #
  ###########
  defp render_block(%Block.Heading{lnb: lnb, level: level, content: content, attrs: attrs}, context) do
    converted = convert(content, lnb, context, true)
    build_ast("h#{level}", normalise_attrs(attrs), converted)
  end


  ##############
  # Blockquote #
  ##############

  defp render_block(%Block.BlockQuote{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
    body = render_ast(blocks, context)
    build_ast("blockquote", normalise_attrs(attrs), body)
  end


  #########
  # Table #
  #########

  defp render_block(%Block.Table{lnb: lnb, header: header, rows: rows, alignments: aligns, attrs: attrs}, context) do
    cols = for _align <- aligns, do: build_ast("col", [], [])
    content = [build_ast("colgroup", [], cols)]
    
    content = if header do
      content ++ build_ast("thead", [], add_table_rows(context, [header], "th", aligns, lnb))
    else
      content
    end

    content = content ++ add_table_rows(context, rows, "td", aligns, lnb)
    content = 
      content
      |> List.flatten

    build_ast("table", normalise_attrs(attrs), content)
  end


  ########
  # Code #
  ########
  defp render_block(%Block.Code{lnb: lnb, language: language, attrs: attrs} = block, %Context{options: options}) do
    class = if language, do: [{"class", code_classes(language, options.code_class_prefix)}], else: []
    lines = options.render_code.(block)
    build_ast("pre", normalise_attrs(attrs), [
      build_ast("code", normalise_attrs(class), lines)
    ])
  end


  #########
  # Lists #
  #########

  defp render_block(%Block.List{lnb: lnb, type: type, blocks: items, attrs: attrs, start: start}, context) do
    content = render_ast(items, context)
    build_ast("#{type}", Enum.concat(normalise_attrs(attrs), list_start_to_attrs(start)), content)
  end

  # format a single paragraph list item, and remove the para tags
  defp render_block(%Block.ListItem{lnb: lnb, blocks: blocks, spaced: false, attrs: attrs}, context)
  when length(blocks) == 1 do
    content = case render_ast(blocks, context) do
      [{ "p", _, text }] -> text
      content -> content
    end
    build_ast("li", normalise_attrs(attrs), content)
  end

  # format a spaced list item
  defp render_block(%Block.ListItem{lnb: lnb, blocks: blocks, attrs: attrs}, context) do
    content = render_ast(blocks, context)
    build_ast("li", normalise_attrs(attrs), content)
  end


  ##################
  # Footnote Block #
  ##################

  defp render_block(%Block.FnList{blocks: footnotes}, context) do
    items = Enum.map(footnotes, fn(note) ->
      blocks = append_footnote_link(note)

      %Block.ListItem{attrs: "#fn:#{note.number}", type: :ol, blocks: blocks}
    end)

    html = render_block(%Block.List{type: :ol, blocks: items}, context)
    build_ast("div", [{"class", "footnotes"}], [build_ast("hr", [], []), html])
  end


  #######################################
  # Isolated IALs are rendered as paras #
  #######################################

  defp render_block(%Block.Ial{verbatim: verbatim}, _context) do
    build_ast("p", [], "{:#{verbatim}}")
  end


  ####################
  # IDDef is ignored #
  ####################

  defp render_block(%Block.IdDef{}, _context), do: nil


  ###########
  # Plugins #
  ###########

  defp render_block(%Block.Plugin{lines: lines, handler: handler}, _context) do
    case handler.as_html(lines) do
      html when is_list(html) -> html
      {html, errors}          -> emit_messages(html, errors)
      html                    -> [html]
    end
  end

  #####################################
  # And here are the inline renderers #
  #####################################

  def br,                  do: build_ast("br")
  def codespan(text),      do: build_ast("code", [{"class", "inline"}], text)
  def em(text),            do: build_ast("em", [], text)
  def strong(text),        do: build_ast("strong", [], text)
  def strikethrough(text), do: build_ast("del", [], text)

  def link(url, text),        do: build_ast("a", [{"href", url}], text)
  def link(url, text, nil),   do: build_ast("a", [{"href", url}], text)
  def link(url, text, title), do: build_ast("a", [{"href", url}, {"title", title}], text)

  def image(path, alt, nil) do
    build_ast("img", [{"src", path}, {"alt", alt}])
  end

  def image(path, alt, title) do
    build_ast("img", [{"src", path}, {"alt", alt}, {"title", title}])
  end

  def footnote_link(ref, backref, number), do: build_ast("a", [{"href", "##{ref}"}, {"id", backref}, {"class", "footnote"}, {"title", "see footnote"}], number)

  # Table rows
  defp add_table_rows(context, rows, tag, aligns, lnb) do
    numbered_rows = rows
      |> Enum.zip(Stream.iterate(lnb, &(&1 + 1)))
    for {row, lnb1} <- numbered_rows, do: build_ast("tr", [], add_tds(context, row, tag, aligns, lnb))
  end

  defp add_tds(context, row, tag, aligns, lnb) do
    Enum.reduce(1..length(row), {[], row}, add_td_fn(context, row, tag, aligns, lnb))
    |> elem(0)
    |> Enum.reverse
  end

  defp add_td_fn(context, row, tag, aligns, lnb) do 
    fn n, {acc, _row} ->
      style = cond do
        align = Enum.at(aligns, n - 1) ->
          {"style", "text-align: #{align}"}
        true ->
          {}
      end
      col = Enum.at(row, n - 1)
      converted = convert(col, lnb,  context, true)
      {[build_ast(tag, [style], converted) | acc], row}
    end
  end

  
  defp build_ast(tag, attrs \\ [], content \\ nil)
  defp build_ast(tag, attrs, content) do
    { tag, attrs, normalise_content(content) }
  end

  defp normalise_attrs(attrs \\ nil, lnb \\ nil)
  defp normalise_attrs(nil, _), do: []
  defp normalise_attrs(attrs, _) when is_list(attrs), do: attrs
  defp normalise_attrs(attrs, lnb) when is_binary(attrs), do: normalise_attrs(parse_attrs(attrs, lnb))
  defp normalise_attrs(%{} = attrs, _) do
    Enum.map(attrs, fn
      { k, v } when is_list(v) -> { k, Enum.join(v, " ") }
      { k, v } -> { k, v }
    end)
  end
  # defp normalise_attrs(%{} = attrs), do: Enum.into(attrs, [])

  defp normalise_content(content \\ nil)
  defp normalise_content(nil), do: []
  defp normalise_content(content) when is_integer(content), do: [Integer.to_string(content)]
  defp normalise_content(content) when is_list(content), do: content
  defp normalise_content(content) when is_binary(content), do: [content]
  defp normalise_content(content), do: content

  defp code_classes(language, prefix) do
   ["" | String.split( prefix || "" )]
     |> Enum.map( fn pfx -> "#{pfx}#{language}" end )
     |> Enum.join(" ")
  end

  defp list_start_to_attrs(""), do: []
  defp list_start_to_attrs(start) do
    case Regex.run(~r{start="(\d+)"}, ~s{#{start}}) do
      nil -> []
      [_, start] -> [{"start", start}]
    end
  end

  ###############################
  # Append Footnote Return Link #
  ###############################

  def append_footnote_link(note=%Block.FnDef{}) do
    # fnlink = build_ast("a", [{"href", "#fnref:#{note.number}"}, {"title", "return to article"}, {"class", "reversefootnote"}], ["&#x21A9;"])
    fnlink = ~s[<a href="#fnref:#{note.number}" title="return to article" class="reversefootnote">&#x21A9;</a>]
    [ last_block | blocks ] = Enum.reverse(note.blocks)
    last_block = append_footnote_link(last_block, fnlink)
    Enum.reverse([last_block | blocks])
    |> List.flatten
  end

  def append_footnote_link(block=%Block.Para{lines: lines}, fnlink) do
    [ last_line | lines ] = Enum.reverse(lines)
    last_line = "#{last_line}&nbsp;#{fnlink}"
    # last_line = build_ast("p", [], lines ++ [fnlink])
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


  #################
  # Other Helpers #
  #################

  defp emit_messages(html, errors) do 
    Earmark.Global.Messages.add_messages(errors)
    html
  end

end