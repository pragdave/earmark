defmodule Earmark2.Scanner do

  import Earmark.Helpers.LeexHelpers, only: [tokenize: 2]

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
    tokenize(line, with: :token_lexer) 
  end


  defp compile_token({desc, symbol}) do
    {Regex.compile("\A#{desc}(.*)\z"), symbol}
  end

  defp match_token({regx, symbol}, line) do
    cond  Regex.run(regx}
  end
  defp next_token(line) do
    tokens
    |> Enum.find_value(&match_token(&1, line))
  end

  defp tokens do
    [
      {"\\\\", :backslash},
      {"\\^", :caret},
    ] |> Enum.map(&compile_token/1)
  end

# BACKTICKS   = `+
# CARET       = \^
# COLON       = :
# DASHES      = -+
# DQUOTE      = "
# EQUALS      = =+
# GT          = >+
# HASHES      = #+
# LACCOLADE   = \{
# LBRACKET    = \[
# LPAREN      = \(
# LT          = <+
# RACCOLADE   = \}
# RBRACKET    = \]
# RPAREN      = \)
# SLASHES     = /+
# SQUOTE      = '
# SYMBOLS     = [&|@$?;,%!§]+
# STARS       = \*+
# TILDES      = ~+
# UNDERSCORES = _+
# WHITESPACE  = \s+

# REST        = [[^\][\(\)-><*_+\s\t"'\\\{\}&|@$?;,%!§]
# TRAILING    = [^\][\(\)><*+\s\t"'\\\{\}&|@^$?;,%!§]
# ALPHANUM    = {rest}{trailing}*

# Rules.

# {BACKSLASH} : {token, {backslash, tokenline, tokenchars}}.
# {BACKSLASH}. : {token, {verbatim, tokenline, dismiss_backslash(tokenchars)}}.
# {BACKTICKS} : {token, {backticks, tokenline, tokenchars}}.
# {CARET} : {token, {caret, tokenline, tokenchars}}.
# {COLON} : {token, {colon, tokenline, tokenchars}}.
# {DASHES} : {token, {dashes, tokenline, tokenchars}}.
# {DQUOTE} : {token, {dquote, tokenline, tokenchars}}.
# {EQUALS} : {token, {equals, tokenline, tokenchars}}.
# {GT} : {token, {gt, tokenline, tokenchars}}.
# {HASHES} : {token, {hashes, tokenline, tokenchars}}.
# {LACCOLADE} : {token, {laccolade, tokenline, tokenchars}}.
# {LBRACKET} : {token, {lbracket, tokenline, tokenchars}}.
# {LPAREN} : {token, {lparen, tokenline, tokenchars}}.
# {LT} : {token, {lt, tokenline, tokenchars}}.
# {RACCOLADE} : {token, {raccolade, tokenline, tokenchars}}.
# {RBRACKET} : {token, {rbracket, tokenline, tokenchars}}.
# {RPAREN} : {token, {rparen, tokenline, tokenchars}}.
# {SLASHES} : {token, {slashes, tokenline, tokenchars}}.
# {SQUOTE} : {token, {squote, tokenline, tokenchars}}.
# {STARS} : {token, {stars, tokenline, tokenchars}}.
# {SYMBOLS} : {token, {symbols, tokenline, tokenchars}}.
# {TILDES} : {token, {tildes, tokenline, tokenchars}}.
# {UNDERSCORES} : {token, {underscores, tokenline, tokenchars}}.
# {WHITESPACE} : {token, {whitespace, tokenline, tokenchars}}.

# {ALPHANUM} : {token, {verbatim, tokenline, tokenchars}}.

  def tokenize(line, table, tokens)
  def tokenize("", _, tokens), do: [{:eol, ""}|tokens] |> Enum.reverse
  def tokenize(line, table, tokens) do
    with {token, rest} <- get_token(line, "", 0), do: tokenize(rest, table, [token|tokens])
  end

  def get_token(codepoints, acc, state)
  def get_token(["+"|tail], _acc, 0), do: {{:plus, "+"}, tail}
  def get_token(["#"|tail], _acc, 0), do: {{:hash, "#"}, tail}
  def get_token([" "|tail], _acc, 0), do: get_token(tail, [" "], 1) 
  def get_token(["0"|tail], _acc, 0), do: get_token(tail, [" "], 3) 
  def get_token(["1"|tail], _acc, 0), do: get_token(tail, [" "], 3) 
  def get_token([cp|tail], _acc, 0), do: get_token(tail, [cp], 2)
  def get_token([" "|tail], acc, 1), do: get_token(tail, [" "|acc], 1)
  def get_token(codepoints, acc, 1), do: {{:ws, acc |> Enum.reverse | Enum.join}, codepoints} 

    
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
#           <0> | p(:plus)  | p(:hash) | g(1)      | g(1)      | g(2)    | g(3) | p(:eol); g(:end)
#         ------+-----------+----------+-----------+-----------+---------+------+-----
#           <1> | s(:ws)    | s(:sw)   | g(1)      | g(1)      | s(:ws)  |s(:ws)| s(:ws)
#         ------+-----------+----------+-----------+-----------+---------+------+-----
#           <2> | s(:ident) | s(:ident)| s(:ident) | s(:ident) | g(2)    | g(2) | s(:ident)
#         ------+-----------+----------+-----------+-----------+---------+------+-----
#           <3> | s(:num)   | s(:num)  | s(:num)   | s(:num)   | s(:num) | g(3) | s(:num)
#
#
# p(token) push char to acc return {token, acc} reset acc and goto state<0>
# g(state) push char to acc and goto state<x>
# s(token) return {token, acc} reset acc and push char and goto state<0>
# r<x> return {token
# 
