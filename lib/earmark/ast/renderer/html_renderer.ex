defmodule Earmark.Ast.Renderer.HtmlRenderer do

  import Earmark.Helpers.HtmlParser

  @moduledoc false

  # Structural Renderer for html blocks
  def render_html_block(lines) do
    case parse_html(lines) do
      [tag] -> tag
      _     -> lines
    end
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

  defp _add_content_to_open(new_content, [{tag, atts, content} | rest]) do
    [{tag, atts, [new_content|content]} | rest]
  end

  defp _close_all_open_tags(open)
  defp _close_all_open_tags([tag]), do: tag
  defp _close_all_open_tags(open) do
    _close_all_open_tags(_close_open_tag(open) )
  end

  defp _close_open_tag([tag, {outer, atts, content} | rest]) do
    [{outer, atts, Enum.reverse([tag|content])} | rest]
  end

  defp _flatten_into_opening(tag, open, result)
  defp _flatten_into_opening(_tag, [], result) do
    result
  end
  defp _flatten_into_opening(tag, [{tag, atts, content}|rest], result) do
    [{tag, atts, Enum.reverse(content) ++ result} | rest]
  end
  # TODO: add atts to "<other>"
  defp _flatten_into_opening(tag, [{other, atts, content}|rest], result) do
    _flatten_into_opening(tag, rest, ["<#{other}#{_string_from_atts(atts)}>" | Enum.reverse(content) ] ++ result)
  end

  defp _string_from_atts(atts) do
    atts
    |> Enum.map(fn {key, val} -> ~s{ #{key}="#{val}"} end)
    |> Enum.join
  end

end
