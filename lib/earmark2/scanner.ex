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
  deftoken :dquote,"\"" 
  deftoken :hashes, "#+"
  deftoken :name, "\\p{L}[\\p{L}\\p{N}]*"
  deftoken :number, "[-+]?\\p{N}+(?:\\.\\p{N}*)?"
  deftoken :stars, "\\*+"
  deftoken :ws,    "\\s+"

  defp get_token(line) do
    match(line) ||
    cond do
      Regex.run(@backslash, line)   -> {{:backslash, "\\"}, ""}
      m = Regex.run(@escaped, line) -> 
        with [_, escaped, rest] <- m, do: {{:verbatim, escaped}, rest}
      true                          -> {{:error, line}, ""}
    end
  end


end

##
#
#  {"\\+", :plus},
#  {"#+",  :hashes},
#  {"\s+", :whitespace},
#  {"\p{L}+", :ident}
#
#         state |   +       |  #       | space     | tab       | alpha   | digit| EOL
#         ------+-----------+----------+-----------+-----------+---------+------+-----
#         :init | p(:plus)  | p(:hash) | g(1)      | g(1)      | g(2)    | g(3) | p(:eol); g(:end)
#         ------+-----------+----------+-----------+-----------+---------+------+-----
#         :ws   | s(:ws)    | s(:sw)   | g(1)      | g(1)      | s(:ws)  |s(:ws)| s(:ws)
#         ------+-----------+----------+-----------+-----------+---------+------+-----
#         :ident| s(:ident) | s(:ident)| s(:ident) | s(:ident) | g(2)    | g(2) | s(:ident)
#         ------+-----------+----------+-----------+-----------+---------+------+-----
#         :num  | s(:num)   | s(:num)  | s(:num)   | s(:num)   | s(:num) | g(3) | s(:num)
#
#
# p(token) push char to acc return {token, acc} reset acc and goto state<0>
# g(state) push char to acc and goto state<x>
# s(token) return {token, acc} reset acc and push char and goto state<0>
# r<x> return {token
# 
