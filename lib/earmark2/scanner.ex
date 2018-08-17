defmodule Earmark2.Scanner do

  use Earmark2.Scanner.Macros
  # import Earmark2.Scanner.Macros

  @moduledoc """
  An interface to the leex lexer `src/token_lexer.xrl`
  """

  
  @doc """
  A single line is feed to the `src/token_lexer.xrl` and
  reconverted into an Elixir tuple

        iex(1)> scan(" 4 - 2")
        [
          whitespace: " ",
          verbatim: "4",
          whitespace: " ",
          verbatim: "-",
          whitespace: " ",
          verbatim: "2"
        ]

  """
  def scan(line) do
    tokenize(line, []) 
  end


  defp tokenize(line, tokens)
  defp tokenize("", tokens), do: tokens |> Enum.reverse
  defp tokenize(line, tokens) do
    with {token, rest} <- get_token(line), do: tokenize(rest, [token|tokens])
  end


  @backslash ~r<\A\\\z>
  @escaped ~r<\A\\(.)(.*)>

  # We define token in the *reverse* order they are searched, thusly
  # it would be best to move the most frequent but also the
  # not too expensive to check downwards, the actual order
  # might not be ideal for the typical Elixir docstrings.
  # In case of performance issues, some research might be
  # in order.
  deftoken :sym,         "[^\\\\]"
  deftoken :at,          "@"
  deftoken :period,      "\\."
  deftoken :caret,       "\\^"
  deftoken :backticks,   "`+"
  deftoken :stars,       "\\*+"
  deftoken :underscores, "_+"
  deftoken :questions,   "\\?+"
  deftoken :exclams,     "!+"
  deftoken :hashes,      "#+"
  deftoken :dashes,      "-+(?!\\p{N})"
  deftoken :pluses,      "\\++(?!\\p{N})"
  deftoken :equals,      "=+"
  deftoken :slashes,     "/+"
  deftoken :tildes,      "~+"
  deftoken :gt,          ">"
  deftoken :lt,          "<"
  deftoken :ampersands,  "&+"
  deftoken :entity,      "(?:&[a-zA-Z][a-zA-Z0-9]*;)|(?:&#[0-9]+;)|(?:&#[xX][0-9a-fA-F]+;)"
  deftoken :bars,        "\\|+"
  deftoken :name,        "\\p{L}[\\p{L}\\p{N}]*"
  deftoken :number,      "[-+]?\\p{N}+(?:\\.\\p{N}*)?"
  deftoken :lbracket,    "\\["
  deftoken :rbracket,    "\\]"
  deftoken :lparen,      "\\("
  deftoken :rparen,      "\\)"
  deftoken :laccolade,   "\\{"
  deftoken :raccolade,   "\\}"
  deftoken :dquote,      "\""
  deftoken :squote,      "'"
  deftoken :colon,       ":"
  deftoken :comma,       ","
  deftoken :semicolon,   ";"
  deftoken :ws,          "\\s+"

  defp get_token(line) do
    match(line) ||
    cond do
      Regex.run(@backslash, line)   -> {{:backslash, "\\"}, ""}
      m = Regex.run(@escaped, line) -> 
        with [_, escaped, rest] <- m, do: {{:verbatim, escaped}, rest}
      true                          -> {{:error, line}, ""}
    end
  end

  defp match(line) do
    @_defined_tokens
    |> Enum.find_value(&match_token(&1, line))
  end

  defp match_token( {token_name, token_rgx}, line ) do
    case Regex.run(token_rgx, line) do
      [_, token_string, rest] -> {{token_name, token_string}, rest}
      _                       -> nil
    end
  end

end
