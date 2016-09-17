defmodule Earmark.Helpers.Kludge do

  use Earmark.Types

  import Earmark.Helpers.LeexHelpers, only: [tokenize: 2]
  import Earmark.Helpers.YeccHelpers, only: [parse: 2]
  import Earmark.Helpers.StringHelpers, only: [behead: 2]

  # Hopfully this will go away in v1.2
  # **********************************
  #
  # Right now it needs to parse the url part of strings according to the following grammar
  #     
  #      start -> ( url )
  #      start -> ( url title )
  #
  #      url   -> ( url )
  #      url   -> [ url ]
  #      url   ->  url_char*
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
    case parse(src, lexer: :link_text_lexer, parser: :link_text_parser) do
      nil -> nil
      {parsed, link_text} -> parse_url(behead(src, parsed)) |> make_result(link_text)
    end
  end

  @type result_acc :: {String.t, String.t, maybe(String.t)}
  @type result :: maybe(result_acc)
  @spec parse_url(tokens) :: result
  defp parse_url(tokens)

  defp parse_url([{:open_paren, _}|rest]), do: parse_inner_url(rest, {"", "", nil})
  defp parse_url(_), do: nil

  @spec parse_inner_url( tokens, result_acc ) :: result
  defp parse_inner_url(tokens, url_title_tuple)

  defp make_result(nil, _), do: nil
  defp make_result({parsed, url, title}, link_text) do
    { "[#{link_text}](#{parsed})", link_text, url, title }
  end
end
