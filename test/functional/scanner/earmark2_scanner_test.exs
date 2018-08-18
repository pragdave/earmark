defmodule Functional.Scanner.Earmark2ScannerTest do
  use ExUnit.Case

  import Earmark2.Scanner, only: [scan: 1, scan_document: 1]
  doctest Earmark2.Scanner, import: true

  describe "scan" do
    [
      { " ",     [{:ws, " ", 1}]},
      { "   ",     [{:ws, "   ", 1}]},
      { "hello", [{:verb, "hello", 1}] },
      { "*hello", [{:stars, "*", 1}, {:verb, "hello", 2}]},
      # 0....+....1...
      { "_hello_world_",
        [{:underscores, "_", 1},
         {:verb, "hello", 2},
         {:underscores, "_", 7},
         {:verb, "world", 8},
         {:underscores, "_", 13}]},
      # 0....+....1
      { "* world**",
        [{:stars, "*", 1},
         {:ws, " ", 2},
         {:verb, "world", 3},
         {:stars, "**", 8}]},
      # 0....+....1
      { "--_>--1",
        [{:dashes, "--", 1},
         {:underscores, "_", 3},
         {:gt, ">", 4},
         {:dashes, "-", 5},
         {:number, "-1", 6}]},
      { "++2", [{:pluses, "+", 1}, {:number, "+2", 2}]},
      { "<\\<", [{:lt, "<", 1}, {:escaped, "\\<", 2}]},
      { "### ##", [{:hashes, "###", 1}, {:ws, " ", 4}, {:hashes, "##", 5}]},
      # 0....+....1
      { "####### H7",
        [{:hashes, "#######", 1},
         {:ws, " ", 8},
         {:verb, "H7", 9}] },
      { "` ``", [{:backticks, "`", 1}, {:ws, " ", 2}, {:backticks, "``", 3}] },
      # 0....+.. ..1 for the \
      { "~~ = ==\"'",
        [{:tildes,"~~", 1},
         {:ws, " ", 3},
         {:equals, "=", 4},
         {:ws, " ", 5},
         {:equals, "==", 6},
         {:dquote, "\"", 8},
         {:squote, "'", 9}]},
      # Quotes are not repeated
      { "/\"\"''", [{:slashes, "/", 1},{:dquote, "\"", 2},{:dquote, "\"", 3},{:squote, "'", 4},{:squote, "'", 5}]},
      # Escapes \_o_/
      { "\\",   [{:backslash, "\\", 1}]}, # Only possible at end of line
      { "\\\\", [{:escaped, "\\\\", 1}]},
      { "\\>\\\"\\_", [{:escaped, "\\>", 1}, {:escaped, "\\\"", 3}, {:escaped, "\\_", 5}]},
      { "[](){}", [{:lbracket, "[", 1}, {:rbracket, "]", 2}, {:lparen, "(", 3}, {:rparen, ")", 4}, {:laccolade, "{", 5}, {:raccolade, "}", 6}]},
      { ":^", [{:colon, ":", 1}, {:caret, "^", 2}]},
      # 0....+...
      { "@|%§||&&",
        [{:at, "@", 1},
         {:bars, "|", 2},
         {:sym, "%", 3},
         {:sym, "§", 4},
         {:bars, "||", 5},
         {:ampersands, "&&", 7} ]},
      # 0....+....1..  
      { "& &gt;&#177;",
        [{:ampersands, "&", 1},
         {:ws, " ", 2},
         {:entity, "&gt;", 3},
         {:entity, "&#177;", 7}]},
      # 0....+....1...
      { "&#xad; &#xax;",
        [{:entity, "&#xad;", 1},
         {:ws, " ", 7}, {:ampersands, "&", 8},
         {:hashes, "#", 9},
         {:verb, "xax", 10},
         {:semicolon, ";", 13}]},
      # 0....+....1
      { "42,  -37.2", [{:number, "42", 1}, {:comma, ",", 3}, {:ws, "  ", 4}, {:number, "-37.2", 6}]},
      # 0....+....
      { "<! ? !!??",
        [{:lt, "<", 1},
         {:exclams, "!", 2},
         {:ws, " ", 3},
         {:questions, "?", 4},
         {:ws, " ", 5},
         {:exclams, "!!", 6},
         {:questions, "??", 8}]},
      # # UTF-8?
      { "éλ", [{:verb, "éλ", 1}]},
    ]
    |> Enum.each( fn {text, result} ->
      test "#{text} is scanned as #{inspect result}" do
        tuple = unquote(Macro.escape result)
        assert scan(unquote(text)) == tuple
      end
    end)
  end

  describe "scan_document" do

    test "single line" do
      #       0....+....1
      lines = "_hello_ 42"
      result = [{1, [{:underscores, "_", 1}, {:verb, "hello", 2}, {:underscores, "_", 7}, {:ws, " ", 8}, {:number, "42", 9}]}]

      assert scan_document(lines) == result
    end

    test "some text" do
      lines = "* what\nis\n----"
      result = [{1, [ {:stars, "*", 1}, {:ws, " ", 2}, {:verb, "what", 3} ]},
                {2, [ {:verb, "is", 1} ]},
                {3, [ {:dashes, "----", 1} ]},  ]

      assert scan_document(lines) == result
    end

    test "from Earmark" do
      lines = """
              ### API

                  * `Earmark.as_html`
                    {:ok, html_doc, []}                = Earmark.as_html(markdown)
                    {:error, html_doc, error_messages} = Earmark.as_html(markdown)

                  * `Earmark.as_html!`
                    html_doc = Earmark.as_html!(markdown, options)

                    Any error messages are printed to _stderr_.
              """
      result = [
         {1, [{:hashes, "###", 1}, {:ws, " ", 4}, {:verb, "API", 5}]},
         {2, []},
         {3, [{:ws, "    ", 1}, {:stars, "*", 5}, {:ws, " ", 6}, {:backticks, "`", 7}, {:verb, "Earmark", 8}, {:period, ".", 15}, {:verb, "as", 16}, {:underscores, "_", 18}, {:verb, "html", 19}, {:backticks, "`", 23}]},
         {4, [{:ws, "      ", 1}, {:laccolade, "{", 7}, {:colon, ":", 8}, {:verb, "ok", 9}, {:comma, ",", 11}, {:ws, " ", 12}, {:verb, "html", 13}, {:underscores, "_", 17}, {:verb, "doc", 18}, {:comma, ",", 21}, {:ws, " ", 22}, {:lbracket, "[", 23}, {:rbracket, "]", 24}, {:raccolade, "}", 25}, {:ws, "                ", 26}, {:equals, "=", 42}, {:ws, " ", 43}, {:verb, "Earmark", 44}, {:period, ".", 51}, {:verb, "as", 52}, {:underscores, "_", 54}, {:verb, "html", 55}, {:lparen, "(", 59}, {:verb, "markdown", 60}, {:rparen, ")", 68}]},
         {5, [{:ws, "      ", 1}, {:laccolade, "{", 7}, {:colon, ":", 8}, {:verb, "error", 9}, {:comma, ",", 14}, {:ws, " ", 15}, {:verb, "html", 16}, {:underscores, "_", 20}, {:verb, "doc", 21}, {:comma, ",", 24}, {:ws, " ", 25}, {:verb, "error", 26}, {:underscores, "_", 31}, {:verb, "messages", 32}, {:raccolade, "}", 40}, {:ws, " ", 41}, {:equals, "=", 42}, {:ws, " ", 43}, {:verb, "Earmark", 44}, {:period, ".", 51}, {:verb, "as", 52}, {:underscores, "_", 54}, {:verb, "html", 55}, {:lparen, "(", 59}, {:verb, "markdown", 60}, {:rparen, ")", 68}]},
         {6, []},
         {7, [{:ws, "    ", 1}, {:stars, "*", 5}, {:ws, " ", 6}, {:backticks, "`", 7}, {:verb, "Earmark", 8}, {:period, ".", 15}, {:verb, "as", 16}, {:underscores, "_", 18}, {:verb, "html", 19}, {:exclams, "!", 23}, {:backticks, "`", 24}]},
         {8, [{:ws, "      ", 1}, {:verb, "html", 7}, {:underscores, "_", 11}, {:verb, "doc", 12}, {:ws, " ", 15}, {:equals, "=", 16}, {:ws, " ", 17}, {:verb, "Earmark", 18}, {:period, ".", 25}, {:verb, "as", 26}, {:underscores, "_", 28}, {:verb, "html", 29}, {:exclams, "!", 33}, {:lparen, "(", 34}, {:verb, "markdown", 35}, {:comma, ",", 43}, {:ws, " ", 44}, {:verb, "options", 45}, {:rparen, ")", 52}]},
         {9, []},
         {10, [{:ws, "      ", 1}, {:verb, "Any", 7}, {:ws, " ", 10}, {:verb, "error", 11}, {:ws, " ", 16}, {:verb, "messages", 17}, {:ws, " ", 25}, {:verb, "are", 26}, {:ws, " ", 29}, {:verb, "printed", 30}, {:ws, " ", 37}, {:verb, "to", 38}, {:ws, " ", 40}, {:underscores, "_", 41}, {:verb, "stderr", 42}, {:underscores, "_", 48}, {:period, ".", 49}]},
         {11, []}, 
        ]

      # Toggle the single assert and the looped assert for debugging
        
      assert scan_document(lines) == result

      # scan_document(lines) 
      # |> Enum.zip(result)
      # |> Enum.each( fn {actual, expected} -> assert actual == expected end )
    end
  end
end
