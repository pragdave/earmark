defmodule Earmark.Helpers.Kludge do

  import Earmark.Helpers.LeexHelpers, only: [tokenize: 2]
  import Earmark.Helpers.YeccHelpers, only: [parse: 2]
  import Earmark.Helpers.StringHelpers, only: [behead: 2]

  # Hopfully this will go away in v1.2
  # **********************************
  #
  # Right now it needs to parse the url part of strings according to the following grammar
  #     
  #      url -> ( inner_url )
  #      url -> ( inner_url title )
  #
  #      inner_url   -> ( inner_url )
  #      inner_url   -> [ inner_url ]
  #      inner_url   ->  url_char*
  #
  #      url_char -> . - quote - ( - ) - [ - ] 
  #      
  #      title -> quote .* quote  ;;   not LALR-k here
  #
  #      quote ->  "
  #      quote ->  '              ;;  yep allowing '...." for now
  #
  #      non_quote -> . - quote

  @doc false
  def parse_link src do
    with {parsed, link_text} <-  parse(src, lexer: :link_text_lexer, parser: :link_text_parser),
    do: p_url(behead(src, parsed)) |> make_result(link_text)
  end

  defp p_url([{:open_paren, _}|ts]), do: url(ts, {[""], [""], nil}, [:close_paren])
  defp p_url(_), do: nil

   
  defp url([{:open_paren, text}|ts], result, needed), do: url(ts, add(result, text), [:close_paren|needed])
  defp url([{:open_bracket, text}|ts], result, needed), do: url(ts, add(result, text), [:close_bracket|needed])
  defp url([{:close_paren, text}|ts], result, [:close_paren|needed), do: url(ts, add(result, text), needed)
  defp url([{:close_paren, _}|_], _, _), do: nil
  defp url([{:close_bracket, text}|ts], result, [:close_bracket|needed), do: url(ts, add(result, text), needed)
  defp url([{:close_bracket, _}|_], _, _), do: nil
  defp url(ts = [{:any_quote, text}|_], result, [:close_paren]), do: bail_out_to_title(ts, add(result, text))
  defp url([{:any_quote, _}|_], _, _), do: nil
  defp url([{:verbatim, text}|ts], result, needed), do: url(ts, add(result, text), needed)
  defp url([], result, []), do: result
  defp url(_, _, _), do: nil

  defp bail_out_to_title(ts, {parsed_text, url_text, nil}) do
    with remaining_text <- ts |> Enum.map(fn {_, text} -> text end) |> Enum.join(""),
    do: 
      case title(remaining_text) do
        nil -> nil
        {title_text, inner_title} -> {"#{parsed_text}#{title_text}", url_text, inner_title}
      end
  end

  # sic!!! Greedy and not context aware, matching '..." and "...' for backward comp
  @title_end_rgx ~r{['"](.*)['"]\)}
  defp title(remaining_text) do 
    case Regex.run(@title_end_rgx) do
      nil -> nil
      [parsed, inner] -> {parsed, inner}
    end
  end

  defp make_result(nil, _), do: nil
  defp make_result({parsed, url, title}, link_text) do
    { "[#{link_text}](#{list_to_text(parsed)})", link_text, list_to_text(url), title }
  end

  defp add({parsed_text, url_text, nil}, text), do: {[text|parsed_text], [text|url_text], nil}

  defp list_to_text(lst), do: lst |> Enum.reverse() |> Enum.join("")
end
