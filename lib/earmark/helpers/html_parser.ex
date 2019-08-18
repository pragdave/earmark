defmodule Earmark.Helpers.HtmlParser do
  @moduledoc false

  import Earmark.Helpers.StringHelpers, only: [behead: 2]

  # Are leading and trailing "-"s ok?
  @tag_head ~r{\A\s*<([-\w]+)\s*}
  def parse_html(string) do
    case Regex.run(@tag_head, string) do
      [all, tag] -> parse_atts(behead(string, all), tag, [], string)
      _          -> parse_closing(string)
    end
  end

  @attribute ~r{\A([-\w]+)=(["'])(.*?)\2\s*}
  defp parse_atts(string, tag, atts, original) do
    case Regex.run(@attribute, string) do 
      [all, name, _delim, value] -> parse_atts(behead(string, all), tag, [{name, value}|atts], original)
      _                          -> parse_tag_tail(string, tag, atts, original)
    end
  end

  @tag_tail  ~r{\A/?>\s*\z}
  defp parse_tag_tail(string, tag, atts, original) do
    if Regex.match?(@tag_tail, string) do
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
