defmodule Functional.Scanner.Earmark2ScannerTest do
  use ExUnit.Case

  import Earmark2.Scanner, only: [scan: 1]

  [
    { " ",     [{:whitespace, " "}]},
    { "   ",     [{:whitespace, "   "}]},
    { "hello", [{:verbatim, "hello"}] },
    { "*hello", [{:stars, "*"}, {:verbatim, "hello"}]},
    { "* world**", [{:stars, "*"}, {:whitespace, " "}, {:verbatim, "world"}, {:stars, "**"}]}, 
    { "--_>", [{:dashes, "--"}, {:underscores, "_"}, {:gt, ">"}]},
    { "<", [{:lt, "<"}]},
    { "### ##", [{:hashes, "###"}, {:whitespace, " "}, {:hashes, "##"}]},
    { "####### H7", [{:hashes, "#######"}, {:whitespace, " "}, {:verbatim, "H7"}] },
    { "` ``", [{:backticks, "`"}, {:whitespace, " "}, {:backticks, "``"}] }, 
    { "~~ = \"'", [{:tildes,"~~"}, {:whitespace, " "},{:equals, "="}, {:whitespace, " "}, {:dquote, "\""}, {:squote, "'"}]},
    # Quotes are not repeated
    { "/\"\"\'\'", [{:slashes, "/"},{:dquote, "\""},{:dquote, "\""},{:squote, "'"},{:squote, "'"}]},
    # Escapes \_o_/
    { "\\",   [{:backslash, "\\"}]}, # Only possible at end of line
    { "\\\\", [{:verbatim, "\\"}]}, 
    { "\\>\\\"\\_", [{:verbatim, ">"}, {:verbatim, "\""}, {:verbatim, "_"}]},
    { "[](){}", [{:lbracket, "["}, {:rbracket, "]"}, {:lparen, "("}, {:rparen, ")"}, {:laccolade, "{"}, {:raccolade, "}"}]},
    { ":^", [{:colon, ":"}, {:caret, "^"}]},
    { "&@|%§", [{:symbols, "&@|%§"}]},
    # UTF-8?
    { "éλ", [{:verbatim, "éλ"}]},
  ]
  |> Enum.each( fn {text, result} ->
    test "#{text} is scanned as #{inspect result}" do
      assert scan(unquote(text)) == unquote(result) 
    end
  end)
end
