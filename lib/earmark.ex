defmodule Earmark do

  def to_html(lines, options = %Earmark.Options{renderer: renderer})
  when is_list(lines)
  do
    { blocks, links } = Earmark.Parser.parse(lines)

    context = %Earmark.Context{options: options, links: links}
    context = Earmark.Inline.update_context(context)

    renderer.render(blocks, context)
  end

  def to_html(lines, options)
  when is_binary(lines)
  do
    to_html(String.split(lines, ~r{\r\n?|\n}), options)
  end
end
