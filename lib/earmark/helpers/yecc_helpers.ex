defmodule Earmark.Helpers.YeccHelpers do
  import Earmark.Helpers.LeexHelpers, only: [lex: 2]

  def parse text, parser: parser, lexer: lexer do 
    case text |> lex(with: lexer)
              |> parser.parse() do
        {:ok, ast}  -> ast
        {:error, _} -> nil
    end
  end

end
