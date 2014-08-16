defmodule Earmark.HtmlRenderer do

  alias  Earmark.Block
  import Earmark.Inline,  only: [ convert: 2 ]
  import Earmark.Helpers, only: [ escape: 1, behead: 2 ]

  def render(blocks, context, map_func) do
    map_func.(blocks, &(render_block(&1, context, map_func)))
    |> IO.iodata_to_binary
  end


  #############
  # Paragraph #
  #############
  def render_block(%Block.Para{lines: lines, attrs: attrs}, context, _mf) do
    lines = convert(lines, context)
    add_attrs("<p>#{lines}</p>\n", attrs)
  end

  ########
  # Html #
  ########
  def render_block(%Block.Html{html: html}, _context, _mf) do
    Enum.intersperse(html, ?\n)
  end

  def render_block(%Block.HtmlOther{html: html}, _context, _mf) do
    Enum.intersperse(html, ?\n)
  end

  #########
  # Ruler #
  #########
  def render_block(%Block.Ruler{type: "-", attrs: attrs}, _context, _mf) do
    add_attrs(~S{<hr/>\n}, attrs, [{"class", ["thin"]}])
  end
  
  def render_block(%Block.Ruler{type: "_", attrs: attrs}, _context, _mf) do
    add_attrs(~S{<hr/>\n}, attrs, [{"class", ["medium"]}])
  end

  def render_block(%Block.Ruler{type: "*", attrs: attrs}, _context, _mf) do
    add_attrs(~S{<hr/>\n}, attrs, [{"class", ["thick"]}])
  end

  ###########
  # Heading #
  ###########
  def render_block(%Block.Heading{level: level, content: content, attrs: attrs}, _context, _mf) do
    html = "<h#{level}>#{content}</h#{level}>\n"
    add_attrs(html, attrs)
  end

  ##############
  # Blockquote #
  ##############

  def render_block(%Block.BlockQuote{blocks: blocks, attrs: attrs}, context, mf) do
    body = render(blocks, context, mf)
    html = "<blockquote>#{body}</blockquote>\n" 
    add_attrs(html, attrs)
  end

  #########
  # Table #
  #########

  def render_block(%Block.Table{header: header, rows: rows, alignments: aligns, attrs: attrs}, context, _mf) do
    cols = for align <- aligns, do: "<col align=\"#{align}\">\n"
    html = [ add_attrs("<table>\n", attrs), "<colgroup>\n", cols, "</colgroup>\n" ]

    if header do
      html = [ html, "<thead>\n",
               add_table_rows(context, [header], "th"),
               "</thead>\n" ]
    end

    html = [ html, add_table_rows(context, rows, "td"), "</table>\n" ]

    html
  end

  ########
  # Code #
  ########
  def render_block(%Block.Code{lines: lines, language: language, attrs: attrs}, _context, _mf) do
    class = if language, do: ~s{ class="#{language}"}, else: ""
    tag = ~s[<pre><code#{class}>]
    lines = lines |> Enum.map(&(escape(&1))) |> Enum.join("\n") |> String.strip
    html = ~s[#{tag}#{lines}</code></pre>\n]
    add_attrs(html, attrs)
  end

  #########
  # Lists #
  #########

  def render_block(%Block.List{type: type, blocks: items, attrs: attrs}, context, mf) do
    content = render(items, context, mf)
    html = "<#{type}>\n#{content}</#{type}>\n"
    add_attrs(html, attrs)
  end

  # format a single paragraph list item, and remove the para tags
  def render_block(%Block.ListItem{blocks: blocks, spaced: false, attrs: attrs}, context, mf)
  when length(blocks) == 1 do
    content = render(blocks, context, mf)
    content = Regex.replace(~r{</?p>}, content, "")
    html = "<li>#{content}</li>\n"
    add_attrs(html, attrs)
  end

  # format a spaced list item
  def render_block(%Block.ListItem{blocks: blocks, attrs: attrs}, context, mf) do
    content = render(blocks, context, mf)
    html = "<li>#{content}</li>\n"
    add_attrs(html, attrs)
  end

  ####################
  # IDDef is ignored #
  ####################

  def render_block(%Block.IdDef{}, _context, _mf) do
    ""
  end

  #####################################
  # And here are the inline renderers #
  #####################################

  def br,             do: "<br/>"
  def codespan(text), do: ~s[<code class="inline">#{text}</code>]
  def em(text),       do: "<em>#{text}</em>"
  def strong(text),   do: "<strong>#{text}</strong>"

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
  def add_table_rows(context, rows, tag) do
    for row <- rows, do: "<tr>\n#{add_tds(context, row, tag)}\n</tr>\n"
  end

  def add_tds(context, row, tag) do
    for col <- row, do: "<#{tag}>#{convert(col, context)}</#{tag}>"
  end

  ##############################################
  # add attributes to the outer tag in a block #
  ##############################################

  def add_attrs(text, attrs_as_string, default_attrs \\ [])

  def add_attrs(text, nil, []), do: text

  def add_attrs(text, nil, default), do: add_attrs(text, "", default)

  def add_attrs(text, attrs, default) do
    default
    |> Enum.into(HashDict.new)
    |> expand(attrs)
    |> attrs_to_string
    |> add_to(text)
  end

  def expand(dict, attrs) do
    cond do
      Regex.match?(~r{^\s*$}, attrs) -> dict

      match = Regex.run(~r{^\.(\S+)\s*}, attrs) ->
        [ leader, class ] = match
        Dict.update(dict, "class", [ class ], &[ class | &1])
        |> expand(behead(attrs, leader))

      match = Regex.run(~r{^\#(\S+)\s*}, attrs) ->
        [ leader, id ] = match
        Dict.update(dict, "id", [ id ], &[ id | &1])
        |> expand(behead(attrs, leader))

      match = Regex.run(~r{^(\S+)=\'([^\']*)'\s*}, attrs) -> #'
        [ leader, name, value ] = match
        Dict.update(dict, name, [ value ], &[ value | &1])
        |> expand(behead(attrs, leader))

      match = Regex.run(~r{^(\S+)=\"([^\"]*)"\s*}, attrs) -> #"
        [ leader, name, value ] = match
        Dict.update(dict, name, [ value ], &[ value | &1])
        |> expand(behead(attrs, leader))

      match = Regex.run(~r{^(\S+)=(\S+)\s*}, attrs) ->
        [ leader, name, value ] = match
        Dict.update(dict, name, [ value ], &[ value | &1])
        |> expand(behead(attrs, leader))

    end
  end

  def attrs_to_string(attrs) do
    (for { name, value } <- attrs, do: ~s/#{name}="#{Enum.join(value, " ")}"/)
    |> Enum.join(" ")                                      
  end                            

  def add_to(attrs, text) do
    Regex.replace(~r/>/, text, " #{attrs}>", global: false)
  end
end
