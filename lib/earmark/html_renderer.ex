defmodule Earmark.HtmlRenderer do

  alias  Earmark.Block
  alias  Earmark.Context
  alias  Earmark.Message
  alias  Earmark.Options
  import Earmark.Inline,  only: [ convert: 2 ]
  import Earmark.Helpers, only: [ escape: 2 ]
  import Earmark.Helpers.AttrParser

  def render(blocks, context=%Context{options: %Options{mapper: mapper}}) do
    {html, messages} =
      mapper.(blocks, &(render_block(&1, context))) |>
      Enum.unzip()
    { IO.iodata_to_binary(html), messages }
  end

  #############
  # Paragraph #
  #############
  defp render_block(%Block.Para{lines: lines, attrs: attrs}, context) do
    lines = convert(lines, context)
    { add_attrs("<p>#{lines}</p>\n", attrs), [] }
  end

  ########
  # Html #
  ########
  defp render_block(%Block.Html{html: html}, _context) do
    { Enum.intersperse(html, ?\n), [] }
  end

  defp render_block(%Block.HtmlOther{html: html}, _context) do
    { Enum.intersperse(html, ?\n), [] }
  end

  #########
  # Ruler #
  #########
  defp render_block(%Block.Ruler{type: "-", attrs: attrs}, _context) do
    { add_attrs("<hr/>\n", attrs, [{"class", ["thin"]}]), [] }
  end

  defp render_block(%Block.Ruler{type: "_", attrs: attrs}, _context) do
    { add_attrs("<hr/>\n", attrs, [{"class", ["medium"]}]), [] }
  end

  defp render_block(%Block.Ruler{type: "*", attrs: attrs}, _context) do
    { add_attrs("<hr/>\n", attrs, [{"class", ["thick"]}]), [] }
  end

  ###########
  # Heading #
  ###########
  defp render_block(%Block.Heading{level: level, content: content, attrs: attrs}, context) do
    html = "<h#{level}>#{convert(content,context)}</h#{level}>\n"
    { add_attrs(html, attrs), [] }
  end

  ##############
  # Blockquote #
  ##############

  defp render_block(%Block.BlockQuote{blocks: blocks, attrs: attrs}, context) do
    {body, messages} = render(blocks, context)
    html = "<blockquote>#{body}</blockquote>\n"
    { add_attrs(html, attrs), messages }
  end

  #########
  # Table #
  #########

  defp render_block(%Block.Table{header: header, rows: rows, alignments: aligns, attrs: attrs}, context) do
    cols = for _align <- aligns, do: "<col>\n"
    html = [ add_attrs("<table>\n", attrs), "<colgroup>\n", cols, "</colgroup>\n" ]

    html = if header do
      [ html, "<thead>\n",
        add_table_rows(context, [header], "th", aligns),
        "</thead>\n" ]
    else
      html
    end

    html = [ html, add_table_rows(context, rows, "td", aligns), "</table>\n" ]

    { html, [] }
  end

  ########
  # Code #
  ########

  defp render_block(%Block.Code{language: language, attrs: attrs} = block, %Context{options: options}) do
    class = if language, do: ~s{ class="#{code_classes( language, options.code_class_prefix)}"}, else: ""
    tag = ~s[<pre><code#{class}>]
    lines = options.render_code.(block)
    html = ~s[#{tag}#{lines}</code></pre>\n]
    { add_attrs(html, attrs), [] }
  end

  #########
  # Lists #
  #########

  defp render_block(%Block.List{type: type, blocks: items, attrs: attrs, start: start}, context) do
    {content, messages} = render(items, context)
    html = "<#{type}#{start}>\n#{content}</#{type}>\n"
    { add_attrs(html, attrs), messages }
  end

  # format a single paragraph list item, and remove the para tags
  defp render_block(%Block.ListItem{blocks: blocks, spaced: false, attrs: attrs}, context)
  when length(blocks) == 1 do
    {content, messages}  = render(blocks, context)
    content = Regex.replace(~r{</?p>}, content, "")
    html = "<li>#{content}</li>\n"
    { add_attrs(html, attrs), messages }
  end

  # format a spaced list item
  defp render_block(%Block.ListItem{blocks: blocks, attrs: attrs}, context) do
    {content, messages} = render(blocks, context)
    html = "<li>#{content}</li>\n"
    { add_attrs(html, attrs), messages }
  end

  ##################
  # Footnote Block #
  ##################

  defp render_block(%Block.FnList{blocks: footnotes}, context) do
    items = Enum.map(footnotes, fn(note) ->
      blocks = append_footnote_link(note)
      %Block.ListItem{attrs: "#fn:#{note.number}", type: :ol, blocks: blocks}
    end)
    { html, messages } = render_block(%Block.List{type: :ol, blocks: items}, context)
    { Enum.join([~s[<div class="footnotes">], "<hr>", html, "</div>"], "\n"), messages }
  end

  #######################################
  # Isolated IALs are rendered as paras #
  #######################################

  defp render_block(%Block.Ial{content: content}, context) do
    { "<p>#{convert(["{:#{content}}"], context)}</p>\n", [] }
  end

  ####################
  # IDDef is ignored #
  ####################

  defp render_block(%Block.IdDef{}, _context) do
    { "", [] }
  end

  ###########
  # Plugins #
  ###########

  defp render_block(%Block.Plugin{lines: lines, handler: handler}, _context) do
    case handler.as_html(lines) do
      {html, messages}        -> {html, Enum.map(messages, &Message.new_message/1)}
      html when is_list(html) -> {html, []}
      html                    -> {[html], []}
    end
  end

  #####################################
  # And here are the inline renderers #
  #####################################

  def br,                  do: "<br/>"
  def codespan(text),      do: ~s[<code class="inline">#{text}</code>]
  def em(text),            do: "<em>#{text}</em>"
  def strong(text),        do: "<strong>#{text}</strong>"
  def strikethrough(text), do: "<del>#{text}</del>"

  def link(url, text),        do: ~s[<a href="#{url}">#{text}</a>]
  def link(url, text, nil),   do: ~s[<a href="#{url}">#{text}</a>]
  def link(url, text, title), do: ~s[<a href="#{url}" title="#{title}">#{text}</a>]

  def image(path, alt, nil) do
    ~s[<img src="#{path}" alt="#{alt}"/>]
  end

  def image(path, alt, title) do
    ~s[<img src="#{path}" alt="#{alt}" title="#{title}"/>]
  end

  def footnote_link(ref, backref, number), do: ~s[<a href="##{ref}" id="#{backref}" class="footnote" title="see footnote">#{number}</a>]

  # Table rows
  def add_table_rows(context, rows, tag, aligns \\ []) do
    for row <- rows, do: "<tr>\n#{add_tds(context, row, tag, aligns)}\n</tr>\n"
  end

  def add_tds(context, row, tag, aligns \\ []) do
    Enum.reduce(1..length(row), {[], row}, fn(n, {acc, row}) ->
      style = cond do
        align = Enum.at(aligns, n - 1) ->
          " style=\"text-align: #{align}\""
        true ->
          ""
      end
      col = Enum.at(row, n - 1)
      {["<#{tag}#{style}>#{convert(col, context)}</#{tag}>" | acc], row}
    end)
    |> elem(0)
    |> Enum.reverse
  end

  ##############################################
  # add attributes to the outer tag in a block #
  ##############################################

  def add_attrs(text, attrs_as_string_or_map, default_attrs \\ [])

  def add_attrs(text, nil, []), do: text

  def add_attrs(text, nil, default), do: add_attrs(text, %{}, default)

  # TODO: Check if the binary form of attrs can be eliminated by parsing attrs in
  #       the parser, as done in the Ial case.
  def add_attrs(text, attrs, default) when is_binary(attrs) do
    with {attrs,_} <- parse_attrs( attrs ), do: add_attrs(text, attrs, default)
  end
  def add_attrs(text, attrs, default) do
    default
    |> Enum.into(attrs)
    |> attrs_to_string
    |> add_to(text)
  end

  def attrs_to_string(attrs) do
    (for { name, value } <- attrs, do: ~s/#{name}="#{Enum.join(value, " ")}"/)
                                                  |> Enum.join(" ")
  end

  def add_to(attrs, text) do
    attrs = if attrs == "", do: "", else: " #{attrs}"
    String.replace(text, ~r{\s?/?>}, "#{attrs}\\0", global: false)
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
end
