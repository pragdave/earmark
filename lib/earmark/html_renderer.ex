defmodule Earmark.HtmlRenderer do

  alias  Earmark.Block
  import Earmark.Inline,  only: [ convert: 2 ]
  import Earmark.Helpers, only: [ escape: 1 ]

  def render(blocks, context) do
    render_reduce(blocks, context, [], &render_block/3)
  end

  defp render_reduce([], _context, result, _func), do: IO.iodata_to_binary(result)
  defp render_reduce([block|rest], context, result, func) do
    render_reduce(rest, context, func.(block, context, result), func)
  end

  #############
  # Paragraph #
  #############
  def render_block(%Block.Para{lines: lines}, context, result) do
    lines = convert(lines, context)
    [ result | "<p>#{lines}</p>\n" ]
  end

  ########
  # Html #
  ########
  def render_block(%Block.Html{html: html}, _context, result) do
    html = Enum.intersperse(html, ?\n)
    [ result | html ]
  end

  def render_block(%Block.HtmlOther{html: html}, _context, result) do
    html = Enum.intersperse(html, ?\n)
    [ result | html ]
  end

  #########
  # Ruler #
  #########
  def render_block(%Block.Ruler{type: "-"}, _context, result) do
    [ result | ~S{<hr class="thin"/>\n} ]
  end

  def render_block(%Block.Ruler{type: "_"}, _context, result) do
    [ result | ~S{<hr class="medium"/>\n} ]
  end

  def render_block(%Block.Ruler{type: "*"}, _context, result) do
    [ result | ~S{<hr class="thick"/>\n} ]
  end

  ###########
  # Heading #
  ###########
  def render_block(%Block.Heading{level: level, content: content}, _context, result) do
    html = "<h#{level}>#{content}</h#{level}>\n"
    [ result | html ]
  end

  ##############
  # Blockquote #
  ##############

  def render_block(%Block.BlockQuote{blocks: blocks}, context, result) do
    body = render(blocks, context)
    [ result | "<blockquote>#{body}</blockquote>\n" ]
  end

  #########
  # Table #
  #########

  def render_block(%Block.Table{header: header, rows: rows, alignments: aligns}, context, result) do
    cols = for align <- aligns, do: "<col align=\"#{align}\">\n"
    html = [ "<table>\n", "<colgroup>\n", cols, "</colgroup>\n" ]

    if header do
      html = [ html, "<thead>\n",
               add_table_rows(context, [header], "th"),
               "</thead>\n" ]
    end

    html = [ html, add_table_rows(context, rows, "td"), "</table>\n" ]
    [ result | html ]
  end

  ########
  # Code #
  ########
  def render_block(%Block.Code{lines: lines, language: language}, _context, result) do
    class = if language, do: ~s{ class="#{language}"}, else: ""
    tag = ~s[<pre><code#{class}>\n]
    lines = lines |> Enum.map(&(escape(&1) <> "\n"))
    [ result | ~s[#{tag}#{lines}</code></pre>\n] ]
  end

  #########
  # Lists #
  #########

  def render_block(%Block.List{type: type, blocks: items}, context, result) do
    content = render(items, context)
    [ result | "<#{type}>\n#{content}</#{type}>\n" ]
  end

  # format a single paragraph list item, and remove the para tags
  def render_block(%Block.ListItem{blocks: blocks, spaced: false}, context, result)
  when length(blocks) == 1 do
    content = render(blocks, context)
    content = Regex.replace(~r{</?p>}, content, "")
    [ result | "<li>#{content}</li>\n" ]
  end

  # format a spaced list item
  def render_block(%Block.ListItem{blocks: blocks}, context, result) do
    content = render(blocks, context)
    [ result | "<li>#{content}</li>\n" ]
  end

  ####################
  # IDDef is ignored #
  ####################

  def render_block(%Block.IdDef{}, _context, result) do
    result
  end

  #####################################
  # And here are the inline renderers #
  #####################################

  def br,             do: "<br/>"
  def codespan(text), do: ~s[<code class="inline">#{text}</code>]
  def em(text), do: "<em>#{text}</em>"
  def strong(text), do: "<strong>#{text}</strong>"

  def link(url, text), do: ~s[<a href="#{url}">#{text}</a>]
  def link(url, text, nil),   do: ~s[<a href="#{url}">#{text}</a>]
  def link(url, text, title), do: ~s[<a href="#{url}" title="#{title}">#{text}</a>]

  def image(path, alt, nil) do
    ~s[<img src="#{path}" alt="#{alt}"/>]
  end

  def image(path, alt, title) do
    ~s[<img src="#{path}" alt="#{alt}" title="#{title}"/>]
  end

  # Table rows
  def add_table_rows(context, rows, tag) do
    for row <- rows, do: "<tr>\n#{add_tds(context, row, tag)}\n</tr>\n"
  end

  def add_tds(context, row, tag) do
    for col <- row, do: "<#{tag}>#{convert(col, context)}</#{tag}>"
  end
end