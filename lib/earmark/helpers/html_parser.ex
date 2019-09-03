defmodule Earmark.Helpers.HtmlParser do

  @moduledoc false

  import Earmark.Helpers.StringHelpers, only: [behead: 2]

  # Are leading and trailing "-"s ok?
  @tag_head ~r{\A\s*<([-\w]+)\s*}
  def parse_html(string, strict \\ true) do
    case Regex.run(@tag_head, string) do
      [all, tag] -> parse_atts(behead(string, all), tag, [], string, strict)
      _          -> parse_closing(string)
    end
  end

  @attribute ~r{\A([-\w]+)=(["'])(.*?)\2\s*}
  defp parse_atts(string, tag, atts, original, strict) do
    case Regex.run(@attribute, string) do 
      [all, name, _delim, value] -> parse_atts(behead(string, all), tag, [{name, value}|atts], original, strict)
      _                          -> parse_tag_tail(string, tag, atts, original, strict)
    end
  end

  @strict_tag_tail  ~r{\A/?>\s*\z}
  @relaxed_tag_tail  ~r{\A/?>\s*.*\z}
  defp parse_tag_tail(string, tag, atts, original, strict) do
    tail = if strict, do: @strict_tag_tail, else: @relaxed_tag_tail
    if Regex.match?(tail, string) do
      {tag, Enum.reverse(atts)}
    else
      original
    end
  end

  @closing_tag ~r{\A\s*</(\w+)>}
  defp parse_closing(string) do
    case Regex.run(@closing_tag, string) do
      [_all, tag] -> {tag}
      _           -> string
    end
  end
end
