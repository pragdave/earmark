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

  def render_block(%Block.List{items: items}, result) do
    content = render(items)
    [ "<ul>\n#{content}\n<\ul>" | result ]
  end

  # format a single paragraph, and remove the para tags
  def render_block(%Block.UlItem{blocks: blocks, spaced: false}, result) 
  when length(blocks) == 1 do
    content = render(blocks)
    content = Regex.replace(~r{</?p>}, content, "")
    [ "<li>#{content}</li>", result ]                             
  end

  # format a spaced list
  def render_block(%Block.UlItem{blocks: blocks}, result) do
    content = render(blocks)
    [ "<li>#{content}</li>", result ]                             
  end

end