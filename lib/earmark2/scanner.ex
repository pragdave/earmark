defmodule Earmark2.Scanner do

  use Earmark2.Scanner.Macros
  alias Earmark.Options

  @moduledoc """
  A lexical Analyzer of markdown documents
  """

  @doc """
  splits a document into lines which are scanned in parallel
  and then reassambles the lines interspersing `:eol` tokens

         iex(0)> lines = [ 
         ...(0)>   "* Hello",
         ...(0)>   "World" ] |> Enum.join("\\n")
         ...(0)> scan_document(lines)
         [{:stars, "*", 1, 1}, {:ws, " ", 1, 2}, {:verb, "Hello", 1, 3}, {:eol, "", 1, 8},
          {:verb, "World", 2, 1}, {:eol, "", 2, 6}]
  """
  def scan_document(doc, options \\ %Options{}) do
    doc
    |> String.split(~r{\r\n?|\n})
    |> Enum.zip(Stream.iterate(1, &(&1+1)))
    |> Earmark.p_flat_map(&scan_tuple/1, options.timeout||5000)
  end
  
  @doc """
  A single line is feed to the `src/token_lexer.xrl` and
  reconverted into an Elixir tuple

        iex(1)> scan(" 4 - 2")
        [
          {:ws, " ", 0, 1},
          {:number, "4", 0, 2},
          {:ws, " ", 0, 3},
          {:dashes, "-", 0, 4},
          {:ws, " ", 0, 5},
          {:number, "2", 0, 6},
        ]
  """
  def scan(line, lnb \\ 0) do
    with {tokens, _} <- tokenize(line, [], lnb), do: tokens |> Enum.reverse
  end

  defp scan_tuple({line, lnb}) do
    with {tokens, col} <- tokenize(line, [], lnb), do: [{:eol, "", lnb, col}|tokens] |> Enum.reverse
  end


  defp tokenize(line, tokens, lnb, col \\ 1)
  defp tokenize("", tokens, _, col), do: {tokens, col}
  defp tokenize(line, tokens, lnb, col) do
    with {token, rest, _, new_col} <- get_token(line, lnb, col), do: tokenize(rest, [token|tokens], lnb, new_col)
  end


  # We define token in the *reverse* order they are searched, thusly
  # it would be best to move the most frequent but also the
  # not too expensive to check downwards, the actual order
  # might not be ideal for the typical Elixir docstrings.
  # In case of performance issues, some research might be
  # in order.
  deftoken :sym,         "[^\\\\]"
  deftoken :backslash,   "\\\\" # can only match at end, do not move down
  deftoken :escaped,     "\\\\."
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
  deftoken :verb,        "\\p{L}[\\p{L}\\p{N}]*"
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

  defp get_token(line, lnb, col) do
    match(line, lnb, col) || {{:error, line, col}, "", lnb, col}
  end

  defp match(line, lnb, col) do
    @_defined_tokens
    |> Enum.find_value(&match_token(&1, line, lnb, col))
  end

  defp match_token( {token_name, token_rgx}, line, lnb, col ) do
    case Regex.run(token_rgx, line) do
      [_, token_string, rest] -> {{token_name, token_string, lnb, col}, rest, lnb, col + String.length(token_string)} 
      _                       -> nil
    end
  end

end
