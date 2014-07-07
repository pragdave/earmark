defmodule Earmark.HtmlRenderer do

  alias Earmark.Block

  def render(blocks) do
    blocks
    |> Enum.reduce([], &render_block/2)
    |> Enum.reverse
    |> Enum.join("\n")
  end


  #############
  # Paragraph #
  #############
  def render_block(%Block.Para{lines: lines}, result) do
    lines = Enum.join(lines, "\n")
    [ "<p>#{lines}</p>" | result ]
  end

  ########
  # Html #
  ########
  def render_block(%Block.Html{html: html, tag: tag}, result) do
    html = Enum.join(html, "\n")
    [ "#{html}\n</#{tag}>" | result ]
  end

  #########
  # Ruler #
  #########
  def render_block(%Block.Ruler{type: "-"}, result) do
    [ ~S{<hr class="thin"/>} | result ]
  end

  def render_block(%Block.Ruler{type: "_"}, result) do
    [ ~S{<hr class="medium"/>} | result ]
  end

  def render_block(%Block.Ruler{type: "*"}, result) do
    [ ~S{<hr class="thick"/>} | result ]
  end

  ###########
  # Heading #
  ###########
  def render_block(%Block.Heading{level: level, content: content}, result) do
    html = "<h#{level}>#{content}</h#{level}>"
    [ html | result ]
  end
     
  ##############
  # Blockquote #
  ##############

  def render_block(%Block.BlockQuote{blocks: blocks}, result) do
    body = render(blocks)
    [ "<blockquote>#{body}</blockquote>" | result ]
  end

  ########
  # Code #
  ########
  def render_block(%Block.Code{lines: lines, language: language}, result) do
    class = if language, do: ~s{ class="#{language}"}, else: ""
    tag = ~s[<pre><code#{class}>]
    lines = Enum.join(lines, "\n")
    [ ~s[#{tag}#{lines}</code></pre>] | result ]
  end

  #########
  # Lists #
  #########

  def render_block(%Block.List{type: type, blocks: items}, result) do
    content = render(items)
    [ "<#{type}>\n#{content}\n<\#{type}>" | result ]
  end

  # format a single paragraph, and remove the para tags
  def render_block(%Block.ListItem{blocks: blocks, spaced: false}, result) 
  when length(blocks) == 1 do
    content = render(blocks)
    content = Regex.replace(~r{</?p>}, content, "")
    [ "<li>#{content}</li>", result ]                             
  end

  # format a spaced list
  def render_block(%Block.ListItem{blocks: blocks}, result) do
    content = render(blocks)
    [ "<li>#{content}</li>", result ]                             
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