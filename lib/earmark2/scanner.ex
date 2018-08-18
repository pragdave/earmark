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
         [{1, [{:stars, "*", 1}, {:ws, " ", 2}, {:verb, "Hello", 3}]},
          {2, [ {:verb, "World", 1}]}]
  """
  def scan_document(doc, options \\ %Options{}) do
    doc
    |> String.split(~r{\r\n?|\n})
    |> Enum.zip(Stream.iterate(1, &(&1+1)))
    |> Earmark.pmap(&scan_line/1, options.timeout||5000)
  end
  

  @doc """
  A single line is feed to the `src/token_lexer.xrl` and
  reconverted into an Elixir tuple

        iex(1)> scan(" 4 - 2")
        [
          {:ws, " ", 1},
          {:number, "4", 2},
          {:ws, " ", 3},
          {:dashes, "-", 4},
          {:ws, " ", 5},
          {:number, "2", 6},
        ]
  """
  def scan(line) do
    with tokens <- tokenize(line, []), do: tokens |> Enum.reverse
  end

  defp scan_line({line, lnb}) do
    with tokens <- tokenize(line, []), do: {lnb, tokens |> Enum.reverse}
  end


  defp tokenize(line, tokens, col \\ 1)
  defp tokenize("", tokens,  col), do: tokens
  defp tokenize(line, tokens, col) do
    with {token, rest, new_col} <- get_token(line, col), do: tokenize(rest, [token|tokens], new_col)
  end


  # We define token in the *reverse* order they are searched, thusly
  # it would be best to move the most frequent but also the
  # not too expensive to check downwards, the actual order
  # might not be ideal for the typical Elixir docstrings.
  # In case of performance issues, some research might be
  # in order.
  deftoken :syms,        "[^-\\]\\\\|+*/~=&;_<>{}]+"
  deftoken :backslash,   "\\\\" # can only match at end, do not move down
  deftoken :verb,        "\\p{L}[\\p{L}\\p{N}]*"
  deftoken :verb,        "#" <> "{8,}"
  deftoken :escaped,     "\\\\."
  deftoken :at,          "@"
  deftoken :period,      "\\."
  deftoken :caret,       "\\^"
  deftoken :backticks,   "`+"
  deftoken :stars,       "\\*+"
  deftoken :underscores, "_+"
  deftoken :questions,   "\\?+"
  deftoken :exclams,     "!+"
  deftoken :hashes,      "#" <> "{1,7}"
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

  defp get_token(line, col) do
    match(line, col) || {{:error, line, col}, "", col}
  end

  defp match(line, col) do
    @_defined_tokens
    |> Enum.find_value(&match_token(&1, line, col))
  end

  defp match_token( {token_name, token_rgx}, line, col ) do
    case Regex.run(token_rgx, line) do
      [_, token_string, rest] -> {{token_name, token_string, col}, rest, col + String.length(token_string)} 
      _                       -> nil
    end
  end

end
