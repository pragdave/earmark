defmodule Functional.Scanner.Earmark2ScannerTest do
  use ExUnit.Case

  import Earmark2.Scanner, only: [scan: 1]
  # doctest Earmark2.Scanner, import: true

  [
    { " ",     [{:ws, " "}]},
    { "   ",     [{:ws, "   "}]},
    { "hello", [{:name, "hello"}] },
    { "*hello", [{:stars, "*"}, {:name, "hello"}]},
    { "* world**", [{:stars, "*"}, {:ws, " "}, {:name, "world"}, {:stars, "**"}]}, 
    { "--_>--1", [{:dashes, "--"}, {:underscores, "_"}, {:gt, ">"}, {:dashes, "-"}, {:number, "-1"}]},
    { "++2", [{:pluses, "+"}, {:number, "+2"}]},
    { "<\\<", [{:lt, "<"}, {:verbatim, "<"}]},
    { "### ##", [{:hashes, "###"}, {:ws, " "}, {:hashes, "##"}]},
    { "####### H7", [{:hashes, "#######"}, {:ws, " "}, {:name, "H7"}] },
    { "` ``", [{:backticks, "`"}, {:ws, " "}, {:backticks, "``"}] }, 
    { "~~ = ==\"'", [{:tildes,"~~"}, {:ws, " "},{:equals, "="}, {:ws, " "}, {:equals, "=="}, {:dquote, "\""}, {:squote, "'"}]},
    # Quotes are not repeated
    { "/\"\"\'\'", [{:slashes, "/"},{:dquote, "\""},{:dquote, "\""},{:squote, "'"},{:squote, "'"}]},
    # Escapes \_o_/
    { "\\",   [{:backslash, "\\"}]}, # Only possible at end of line
    { "\\\\", [{:verbatim, "\\"}]}, 
    { "\\>\\\"\\_", [{:verbatim, ">"}, {:verbatim, "\""}, {:verbatim, "_"}]},
    { "[](){}", [{:lbracket, "["}, {:rbracket, "]"}, {:lparen, "("}, {:rparen, ")"}, {:laccolade, "{"}, {:raccolade, "}"}]},
    { ":^", [{:colon, ":"}, {:caret, "^"}]},
    { "@|%§||&&", [{:at, "@"}, {:bars, "|"}, {:sym, "%"}, {:sym, "§"}, {:bars, "||"}, {:ampersands, "&&"} ]},
    { "& &gt;&#177;", [{:ampersands, "&"}, {:ws, " "}, {:entity, "&gt;"}, {:entity, "&#177;"}]},
    { "&#xad; &#xax;", [{:entity, "&#xad;"}, {:ws, " "}, {:ampersands, "&"}, {:hashes, "#"}, {:name, "xax"}, {:semicolon, ";"}]},
    { "42,  -37.2", [{:number, "42"}, {:comma, ","}, {:ws, "  "}, {:number, "-37.2"}]},
    { "<! ? !!??", [{:lt, "<"}, {:exclams, "!"}, {:ws, " "}, {:questions, "?"}, {:ws, " "}, {:exclams, "!!"}, {:questions, "??"}]},
    # UTF-8?
    { "éλ", [{:name, "éλ"}]},
  ]
  |> Enum.each( fn {text, result} ->
    test "#{text} is scanned as #{inspect result}" do
      assert scan(unquote(text)) == unquote(result) 
    end
  end)
end
