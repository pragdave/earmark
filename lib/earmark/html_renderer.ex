defmodule Earmark.HtmlRenderer do

  alias  Earmark.Block
  import Earmark.Inline,  only: [ convert: 2 ]
  import Earmark.Helpers, only: [ escape: 1 ]

  def render(blocks, context) do
    render_reduce(blocks, context, [], &render_block/3)
    |> Enum.join("\n")
  end


  defp render_reduce([], _context, result, _func), do: Enum.reverse(result)
  defp render_reduce([block|rest], context, result, func) do
    render_reduce(rest, context, func.(block, context, result), func)
  end

  #############
  # Paragraph #
  #############
  def render_block(%Block.Para{lines: lines}, context, result) do
    lines = convert(lines, context)
    [ "<p>#{lines}</p>" | result ]
  end

  ########
  # Html #
  ########
  def render_block(%Block.Html{html: html}, _context, result) do
    html = Enum.join(html, "\n")
    [ html | result ]
  end

  def render_block(%Block.HtmlOther{html: html}, _context, result) do
    html = Enum.join(html, "\n")
    [ "#{html}" | result ]
  end

  #########
  # Ruler #
  #########
  def render_block(%Block.Ruler{type: "-"}, _context, result) do
    [ ~S{<hr class="thin"/>} | result ]
  end

  def render_block(%Block.Ruler{type: "_"}, _context, result) do
    [ ~S{<hr class="medium"/>} | result ]
  end

  def render_block(%Block.Ruler{type: "*"}, _context, result) do
    [ ~S{<hr class="thick"/>} | result ]
  end

  ###########
  # Heading #
  ###########
  def render_block(%Block.Heading{level: level, content: content}, _context, result) do
    html = "<h#{level}>#{content}</h#{level}>"
    [ html | result ]
  end
     
  ##############
  # Blockquote #
  ##############

  def render_block(%Block.BlockQuote{blocks: blocks}, context, result) do
    body = render(blocks, context)
    [ "<blockquote>#{body}</blockquote>" | result ]
  end

  ########
  # Code #
  ########
  def render_block(%Block.Code{lines: lines, language: language}, _context, result) do
    class = if language, do: ~s{ class="#{language}"}, else: ""
    tag = ~s[<pre><code#{class}>]
    lines = lines |> Enum.map(&escape/1) |> Enum.join("\n")
    [ ~s[#{tag}#{lines}</code></pre>] | result ]
  end

  #########
  # Lists #
  #########

  def render_block(%Block.List{type: type, blocks: items}, context, result) do
    content = render(items, context)
    [ "<#{type}>\n#{content}\n</#{type}>" | result ]
  end

  # format a single paragraph list item, and remove the para tags
  def render_block(%Block.ListItem{blocks: blocks, spaced: false}, context, result) 
  when length(blocks) == 1 do
    content = render(blocks, context)
    content = Regex.replace(~r{</?p>}, content, "")
    [ "<li>#{content}</li>" | result ]                             
  end

  # format a spaced list item
  def render_block(%Block.ListItem{blocks: blocks}, context, result) do
    content = render(blocks, context)
    [ "<li>#{content}</li>" | result ]                             
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

end