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
    # { "--_>", [{:dashes, "--"}, {:underscores, "_"}, {:gt, ">"}]},
    # { "<", [{:lt, "<"}]},
    # { "### ##", [{:hashes, "###"}, {:ws, " "}, {:hashes, "##"}]},
    # { "####### H7", [{:hashes, "#######"}, {:ws, " "}, {:name, "H7"}] },
    # # { "` ``", [{:backticks, "`"}, {:whitespace, " "}, {:backticks, "``"}] }, 
    # # { "~~ = \"'", [{:tildes,"~~"}, {:whitespace, " "},{:equals, "="}, {:whitespace, " "}, {:dquote, "\""}, {:squote, "'"}]},
    # # Quotes are not repeated
    # # { "/\"\"\'\'", [{:slashes, "/"},{:dquote, "\""},{:dquote, "\""},{:squote, "'"},{:squote, "'"}]},
    # # Escapes \_o_/
    { "\\",   [{:backslash, "\\"}]}, # Only possible at end of line
    { "\\\\", [{:verbatim, "\\"}]}, 
    # # { "\\>\\\"\\_", [{:verbatim, ">"}, {:verbatim, "\""}, {:verbatim, "_"}]},
    # # { "[](){}", [{:lbracket, "["}, {:rbracket, "]"}, {:lparen, "("}, {:rparen, ")"}, {:laccolade, "{"}, {:raccolade, "}"}]},
    # # { ":^", [{:colon, ":"}, {:caret, "^"}]},
    # # { "&@|%§", [{:symbols, "&@|%§"}]},
    { "42", [{:number, "42"}]},
    # UTF-8?
    { "éλ", [{:name, "éλ"}]},
  ]
  |> Enum.each( fn {text, result} ->
    test "#{text} is scanned as #{inspect result}" do
      assert scan(unquote(text)) == unquote(result) 
    end
  end)
end
