defmodule Earmark2.Scanner do

  use Earmark2.Scanner.Macros
  alias Earmark.Options
  alias Earmark2.Line

  @moduledoc """
  A lexical Analyzer of markdown documents
  """


  @doc """
  Scans a line into tokens.
        iex(0)>

  """
  def scan_lines(lines), do: lines |> Stream.zip(Stream.iterate(1, &(&1+1))) |> Enum.flat_map(&scan_line/1)

  @doc """
    Used by `scan_lines`
  """
  def scan_line({line, lnb}), do: tokenize(line, [], {lnb, 1}) |> Enum.reverse


  defp tokenize(line, tokens, location)
  defp tokenize("", [],  location), do: [{:st_blank, "", location}]
  defp tokenize("", tokens,  _), do: tokens
  defp tokenize(line, tokens, {lnb, col}) do
    with {token, rest, new_col} <- get_token(line, {lnb, col}), do: tokenize(rest, [token|tokens], {lnb, new_col})
  end


  # We define token in the *reverse* order they are searched, thusly
  # it would be best to move the most frequent but also the
  # not too expensive to check downwards, the actual order
  # might not be ideal for the typical Elixir docstrings.
  # In case of performance issues, some research might be
  # in order.

  @id_title_part ~S"""
        (?|
             " (.*)  "         # in quotes
          |  ' (.*)  '         #
          | \( (.*) \)         # in parens
        )
  """

  @id_title_part_re ~r[^\s*#{@id_title_part}\s*$]x


  @always_text "[^-\\]\\\\|+*~<>{\\}[`!'==#=\\d" <> ~s{"} <> "]"
  @text_after  "[^-\\]\\\\|+*~<>{}[`!]"
  # deftoken :backslash,   "\\\\" # can only match at end, do not move down
  # deftoken :escaped,     "\\\\."
  deftoken :backticks,   "`+"
  # deftoken :stars,       "\\*+"
  # deftoken :underscores, "_+"
  # deftoken :text,        "#" <> "{8,}#{@text_after}"
  # deftoken :hashes,      "#" <> "{1,7}"
  # deftoken :dashes,      "-+"
  # deftoken :pluses,      "\\++"
  # deftoken :equals,      "=+"
  # deftoken :tildes,      "~+"
  # deftoken :gt,          ">"
  # deftoken :lt,          "<"
  # deftoken :exclam,      "!"
  # deftoken :caret,       "\\^"
  # deftoken :bars,        "\\|+"
  # deftoken :lbracket,    "\\["
  # deftoken :rbracket,    "\\]"
  # deftoken :laccolade,   "\\{"
  # deftoken :raccolade,   "\\}"
  # deftoken :dquote,      "\""
  # deftoken :squote,      "'"
  # deftoken :colon,       ":"
  # deftoken :ws,          "\\s+"
  deftoken :text,        "#{@always_text}#{@text_after}*"

  # tokens matching only at the start of a line
  # deftokenstart :st_setext, "=+\\s*\\z"
  # deftokenstart :st_atx,    "#" <> "{1,6}\\s+"
  # deftokenstart :st_indent, "\\s+"
  deftokenstart :st_ul,     "\\s*[-*]\\s+"
  deftokenstart :st_ol,     "\\s*\\d+\\.\\s+"
  deftokenstart :st_fence,  "\\s*(?:```|~~~).*"

  defp get_token(line, {lnb, col}) do
    match(line, {lnb, col}) || {{:error, line, {lnb, col}}, "", col}
  end

  defp match(line, location)
  defp match(line, loc={_, 1}) do
    @_tokens_at_start
    |> Enum.find_value(&match_token(&1, line, loc))
  end
  defp match(line, loc) do
    @_tokens_inside
    |> Enum.find_value(&match_token(&1, line, loc))
  end

  defp match_token( {token_name, token_rgx}, line, loc={_, col} ) do
    case Regex.run(token_rgx, line) do
      [_, token_string, rest] -> {{token_name, token_string, loc}, rest, col + String.length(token_string)} 
      _                       -> nil
    end
  end

end
