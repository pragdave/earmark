defmodule Earmark.Ast.Renderer.HtmlRenderer do

  import Earmark.Helpers.HtmlParser

  @moduledoc false

  # Structural Renderer for html blocks
  def render_html_block(lines) do
    with [tag] <- parse_html(lines), do: tag
  end

  def render_html_oneline([line|_]) do
    parse_html([line])
  end
  
  @html_comment_start ~r{\A\s*<!--}
  @html_comment_end ~r{-->.*\z}
  def render_html_comment_line(line) do
    line
    |> String.replace(@html_comment_start, "")
    |> String.replace(@html_comment_end, "")
  end

end
