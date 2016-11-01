defmodule Earmark.Helpers.LeexHelpers do
  @doc """
    Allows to lex an Elixir string with a leex lexer and returns
    the tokens as needed for a yecc parser.
  """
  def lex text, with: lexer do
    case text
      |> String.to_char_list()
      |> lexer.string() do
        {:ok, tokens, _} -> tokens
      end
  end

  def tokenize line, with: lexer do
    {:ok, tokens, _} =
    line
    |> to_char_list()
    |> lexer.string()
    elixirize_tokens(tokens,[])
    |> Enum.reverse()
  end

  defp elixirize_tokens(tokens, rest)
  defp elixirize_tokens([], result), do: result
  defp elixirize_tokens([{token, _, text}|rest], result), do: elixirize_tokens(rest, [{token,to_string(text)}|result])

end
