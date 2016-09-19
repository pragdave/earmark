defmodule Earmark.Helpers.Kludge do

  import Tools.Tracer
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
  deft parse_link( src ) do
    with {link_text, parsed_text} <-  parse(src, lexer: :link_text_lexer, parser: :link_text_parser),
         beheaded                    <-  behead(src, to_string(parsed_text)),
         tokens                      <-  tokenize(beheaded, with: :link_text_lexer) do
           IO.inspect beheaded
           IO.inspect tokens
       p_url(tokens) |> make_result(to_string(link_text))
     end
  end

  deft p_url([{:open_paren, _}|ts]), do: url(ts, {[""], [""], nil}, [:close_paren])
  deft p_url(_), do: nil

   
  deft url([{:open_paren, text}|ts], result, needed), do: url(ts, add(result, text), [:close_paren|needed])
  deft url([{:open_bracket, text}|ts], result, needed), do: url(ts, add(result, text), [:close_bracket|needed])
  deft url([{:close_paren, _}], result, [:close_paren]), do: result
  deft url([{:close_paren, text}|ts], result, [:close_paren|needed]), do: url(ts, add(result, text), needed)
  deft url([{:close_paren, _}|_], _, _), do: nil
  deft url([{:close_bracket, text}|ts], result, [:close_bracket|needed]), do: url(ts, add(result, text), needed)
  deft url([{:close_bracket, _}|_], _, _), do: nil
  deft url(ts = [{:any_quote, text}|_], result, [:close_paren]), do: bail_out_to_title(ts, add(result, text))
  deft url([{:any_quote, _}|_], _, _), do: nil
  deft url([{:verbatim, text}|ts], result, needed), do: url(ts, add(result, text), needed)
  deft url([{:escaped, text}|ts], result, needed), do: url(ts, add(result, text), needed)
  deft url([], result, []), do: result
  deft url(_, _, _), do: nil

  defp bail_out_to_title(ts, {parsed_text, url_text, nil}) do
    with remaining_text <- ts |> Enum.map(fn {_, text} -> text end) |> Enum.join("") do 
      case title(remaining_text) do
        nil -> nil
        {title_text, inner_title} -> {"#{parsed_text}#{title_text}", url_text, inner_title}
      end
    end
  end

  # sic!!! Greedy and not context aware, matching '..." and "...' for backward comp
  @title_end_rgx ~r{['"](.*)['"]\)}
  defp title(remaining_text) do 
    case Regex.run(@title_end_rgx, remaining_text) do
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
