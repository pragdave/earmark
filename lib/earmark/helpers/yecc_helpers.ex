defmodule Earmark.Helpers.YeccHelpers do
  import Earmark.Helpers.LeexHelpers, only: [lex: 2]

  def parse!(text, lexer: lexer, parser: parser) do
    case parse(text, lexer: lexer, parser: parser) do
      {:ok, ast} -> ast
      {:error, _} -> nil
    end
  end

  def parse(text, lexer: lexer, parser: parser) do
    with tokens <- lex(text, with: lexer) do
      parser.parse(tokens)
    end
  end
end
