defmodule Earmark.Helpers.LinkParser do

  import Earmark.Helpers.LeexHelpers, only: [tokenize: 2]
  import Earmark.Helpers.YeccHelpers, only: [parse!: 2]
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
  def parse_link( src ) do
    with {link_text, parsed_text} <- parse!(src, lexer: :link_text_lexer, parser: :link_text_parser),
         beheaded                 <- behead(src, to_string(parsed_text)),
         tokens                   <- tokenize(beheaded, with: :link_text_lexer) do
       p_url(tokens) |> make_result(to_string(link_text), to_string(parsed_text))
     end
  end

  defp p_url([{:open_paren, _}|ts]), do: url(ts, {[], [], nil}, [:close_paren])
  defp p_url(_), do: nil


  # push one level
  defp url([{:open_paren, text}|ts], result, needed), do: url(ts, add(result, text), [:close_paren|needed])
  # pop last level
  defp url([{:close_paren, _}|_], result, [:close_paren]), do: result
  # pop inner level
  defp url([{:close_paren, text}|ts], result, [:close_paren|needed]), do: url(ts, add(result, text), needed)
  # A quote on level 0 -> bailing out if there is a matching quote
  defp url(ts_all = [{:open_title, text}|ts], result, [:close_paren]) do
    case bail_out_to_title(ts_all, result) do
      nil -> url(ts, add(result, text), [:close_paren])
      res -> res
    end
  end
  # All these are just added to the url
  defp url([{:open_bracket, text}|ts], result, needed), do: url(ts, add(result, text), needed)
  defp url([{:close_bracket, text}|ts], result, needed), do: url(ts, add(result, text), needed)
  defp url([{:any_quote, text}|ts], result, needed), do: url(ts, add(result, text), needed)
  defp url([{:verbatim, text}|ts], result, needed), do: url(ts, add(result, text), needed)
  defp url([{:escaped, text}|ts], result, needed), do: url(ts, add(result, text), needed)
  # That is not good, actually this is not a legal url part of a link
  defp url(_, _, _), do: nil

  defp bail_out_to_title(ts, result) do
    with remaining_text <- ts |> Enum.map(&text_of_token/1) |> Enum.join("") do
      case title(remaining_text) do
        nil -> nil
        {title_text, inner_title} -> add_title( result, {title_text, inner_title} )
      end
    end
  end

  defp text_of_token(token)
  defp text_of_token({:escaped, text}), do: "\\#{text}"
  defp text_of_token({_, text}), do: text

  # sic!!! Greedy and not context aware, matching '..." and "...' for backward comp
  @title_end_rgx ~r{\s+['"](.*)['"](?=\))}
  defp title(remaining_text) do
    case Regex.run(@title_end_rgx, remaining_text) do
      nil -> nil
      [parsed, inner] -> {parsed, inner}
    end
  end

  defp make_result(nil, _, _), do: nil
  defp make_result({parsed, url, title}, link_text, "!" <> _) do
    { "![#{link_text}](#{list_to_text(parsed)})", link_text, list_to_text(url), title }
  end
  defp make_result({parsed, url, title}, link_text, _) do
    { "[#{link_text}](#{list_to_text(parsed)})", link_text, list_to_text(url), title }
  end

  defp add({parsed_text, url_text, nil}, text), do: {[text|parsed_text], [text|url_text], nil}
  defp add_title({parsed_text, url_text, _}, {parsed,inner}), do: {[parsed|parsed_text], url_text, inner}

  defp list_to_text(lst), do: lst |> Enum.reverse() |> Enum.join("")
end
