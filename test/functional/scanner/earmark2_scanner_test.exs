defmodule Functional.Scanner.Earmark2ScannerTest do
  use ExUnit.Case

  import Earmark2.Scanner, only: [scan: 1, scan_document: 1]
  doctest Earmark2.Scanner, import: true

  describe "scan" do
    [
      { " ",     [{:ws, " ", 0, 1}]},
      { "   ",     [{:ws, "   ", 0, 1}]},
      { "hello", [{:verb, "hello", 0, 1}] },
      { "*hello", [{:stars, "*", 0, 1}, {:verb, "hello", 0, 2}]},
      # 0....+....1...
      { "_hello_world_",
        [{:underscores, "_", 0, 1},
         {:verb, "hello", 0, 2},
         {:underscores, "_", 0, 7},
         {:verb, "world", 0, 8},
         {:underscores, "_", 0, 13}]},
      # 0....+....1
      { "* world**",
        [{:stars, "*", 0, 1},
         {:ws, " ", 0, 2},
         {:verb, "world", 0, 3},
         {:stars, "**", 0, 8}]},
      # 0....+....1
      { "--_>--1",
        [{:dashes, "--", 0, 1},
         {:underscores, "_", 0, 3},
         {:gt, ">", 0, 4},
         {:dashes, "-", 0, 5},
         {:number, "-1", 0, 6}]},
      { "++2", [{:pluses, "+", 0, 1}, {:number, "+2", 0, 2}]},
      { "<\\<", [{:lt, "<", 0, 1}, {:escaped, "\\<", 0, 2}]},
      { "### ##", [{:hashes, "###", 0, 1}, {:ws, " ", 0, 4}, {:hashes, "##", 0, 5}]},
      # 0....+....1
      { "####### H7",
        [{:hashes, "#######", 0, 1},
         {:ws, " ", 0, 8},
         {:verb, "H7", 0, 9}] },
      { "` ``", [{:backticks, "`", 0, 1}, {:ws, " ", 0, 2}, {:backticks, "``", 0, 3}] },
      # 0....+.. ..1 for the \
      { "~~ = ==\"'",
        [{:tildes,"~~", 0, 1},
         {:ws, " ", 0, 3},
         {:equals, "=", 0, 4},
         {:ws, " ", 0, 5},
         {:equals, "==", 0, 6},
         {:dquote, "\"", 0, 8},
         {:squote, "'", 0, 9}]},
      # Quotes are not repeated
      { "/\"\"''", [{:slashes, "/", 0, 1},{:dquote, "\"", 0, 2},{:dquote, "\"", 0, 3},{:squote, "'", 0, 4},{:squote, "'", 0, 5}]},
      # Escapes \_o_/
      { "\\",   [{:backslash, "\\", 0, 1}]}, # Only possible at end of line
      { "\\\\", [{:escaped, "\\\\", 0, 1}]},
      { "\\>\\\"\\_", [{:escaped, "\\>", 0, 1}, {:escaped, "\\\"", 0, 3}, {:escaped, "\\_", 0, 5}]},
      { "[](){}", [{:lbracket, "[", 0, 1}, {:rbracket, "]", 0, 2}, {:lparen, "(", 0, 3}, {:rparen, ")", 0, 4}, {:laccolade, "{", 0, 5}, {:raccolade, "}", 0, 6}]},
      { ":^", [{:colon, ":", 0, 1}, {:caret, "^", 0, 2}]},
      # 0....+...
      { "@|%§||&&",
        [{:at, "@",   0, 1},
         {:bars, "|", 0, 2},
         {:sym, "%",  0, 3},
         {:sym, "§",  0, 4},
         {:bars, "||",0, 5},
         {:ampersands, "&&", 0, 7} ]},
      # 0....+....1..  
      { "& &gt;&#177;",
        [{:ampersands, "&", 0, 1},
         {:ws, " ", 0, 2},
         {:entity, "&gt;", 0, 3},
         {:entity, "&#177;", 0, 7}]},
      # 0....+....1...
      { "&#xad; &#xax;",
        [{:entity, "&#xad;", 0, 1},
         {:ws, " ", 0, 7}, {:ampersands, "&", 0, 8},
         {:hashes, "#", 0, 9},
         {:verb, "xax", 0, 10},
         {:semicolon, ";", 0, 13}]},
      # 0....+....1
      { "42,  -37.2", [{:number, "42", 0, 1}, {:comma, ",", 0, 3}, {:ws, "  ", 0, 4}, {:number, "-37.2", 0, 6}]},
      # 0....+....
      { "<! ? !!??",
        [{:lt, "<", 0, 1},
         {:exclams, "!", 0, 2},
         {:ws, " ", 0, 3},
         {:questions, "?", 0, 4},
         {:ws, " ", 0, 5},
         {:exclams, "!!", 0, 6},
         {:questions, "??", 0, 8}]},
      # # UTF-8?
      { "éλ", [{:verb, "éλ", 0, 1}]},
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
      result = [{:underscores, "_", 1, 1}, {:verb, "hello", 1, 2}, {:underscores, "_", 1, 7}, {:ws, " ", 1, 8}, {:number, "42", 1, 9}, {:eol, "", 1, 11}]

      assert scan_document(lines) == result
    end

    test "some text" do
      lines = "* what\nis\n----"
      result = [{:stars, "*", 1, 1}, {:ws, " ", 1, 2}, {:verb, "what", 1, 3}, {:eol, "", 1, 7},
                {:verb, "is", 2, 1}, {:eol, "", 2, 3},
                {:dashes, "----", 3, 1}, {:eol, "", 3, 5}]

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
      result =
        [{:hashes, "###", 1, 1}, {:ws, " ", 1, 4}, {:verb, "API", 1, 5}, {:eol, "", 1, 8},
         {:eol, "", 2, 1},
         {:ws, "    ", 3, 1}, {:stars, "*", 3, 5}, {:ws, " ", 3, 6}, {:backticks, "`", 3, 7}, {:verb, "Earmark", 3, 8}, {:period, ".", 3, 15}, {:verb, "as", 3, 16}, {:underscores, "_", 3, 18}, {:verb, "html", 3, 19}, {:backticks, "`", 3, 23}, {:eol, "", 3, 24},
         {:ws, "      ", 4, 1}, {:laccolade, "{", 4, 7}, {:colon, ":", 4, 8}, {:verb, "ok", 4, 9}, {:comma, ",", 4, 11}, {:ws, " ", 4, 12}, {:verb, "html", 4, 13}, {:underscores, "_", 4, 17}, {:verb, "doc", 4, 18}, {:comma, ",", 4, 21}, {:ws, " ", 4, 22}, {:lbracket, "[", 4, 23}, {:rbracket, "]", 4, 24}, {:raccolade, "}", 4, 25}, {:ws, "                ", 4, 26}, {:equals, "=", 4, 42}, {:ws, " ", 4, 43}, {:verb, "Earmark", 4, 44}, {:period, ".", 4, 51}, {:verb, "as", 4, 52}, {:underscores, "_", 4, 54}, {:verb, "html", 4, 55}, {:lparen, "(", 4, 59}, {:verb, "markdown", 4, 60}, {:rparen, ")", 4, 68}, {:eol, "", 4, 69},
         {:ws, "      ", 5, 1}, {:laccolade, "{", 5, 7}, {:colon, ":", 5, 8}, {:verb, "error", 5, 9}, {:comma, ",", 5, 14}, {:ws, " ", 5, 15}, {:verb, "html", 5, 16}, {:underscores, "_", 5, 20}, {:verb, "doc", 5, 21}, {:comma, ",", 5, 24}, {:ws, " ", 5, 25}, {:verb, "error", 5, 26}, {:underscores, "_", 5, 31}, {:verb, "messages", 5, 32}, {:raccolade, "}", 5, 40}, {:ws, " ", 5, 41}, {:equals, "=", 5, 42}, {:ws, " ", 5, 43}, {:verb, "Earmark", 5, 44}, {:period, ".", 5, 51}, {:verb, "as", 5, 52}, {:underscores, "_", 5, 54}, {:verb, "html", 5, 55}, {:lparen, "(", 5, 59}, {:verb, "markdown", 5, 60}, {:rparen, ")", 5, 68}, {:eol, "", 5, 69},
         {:eol, "", 6, 1},
         {:ws, "    ", 7, 1}, {:stars, "*", 7, 5}, {:ws, " ", 7, 6}, {:backticks, "`", 7, 7}, {:verb, "Earmark", 7, 8}, {:period, ".", 7, 15}, {:verb, "as", 7, 16}, {:underscores, "_", 7, 18}, {:verb, "html", 7, 19}, {:exclams, "!", 7, 23}, {:backticks, "`", 7, 24}, {:eol, "", 7, 25},
         {:ws, "      ", 8, 1}, {:verb, "html", 8, 7}, {:underscores, "_", 8, 11}, {:verb, "doc", 8, 12}, {:ws, " ", 8, 15}, {:equals, "=", 8, 16}, {:ws, " ", 8, 17}, {:verb, "Earmark", 8, 18}, {:period, ".", 8, 25}, {:verb, "as", 8, 26}, {:underscores, "_", 8, 28}, {:verb, "html", 8, 29}, {:exclams, "!", 8, 33}, {:lparen, "(", 8, 34}, {:verb, "markdown", 8, 35}, {:comma, ",", 8, 43}, {:ws, " ", 8, 44}, {:verb, "options", 8, 45}, {:rparen, ")", 8, 52}, {:eol, "", 8, 53},
         {:eol, "", 9, 1},
         {:ws, "      ", 10, 1}, {:verb, "Any", 10, 7}, {:ws, " ", 10, 10}, {:verb, "error", 10, 11}, {:ws, " ", 10, 16}, {:verb, "messages", 10, 17}, {:ws, " ", 10, 25}, {:verb, "are", 10, 26}, {:ws, " ", 10, 29}, {:verb, "printed", 10, 30}, {:ws, " ", 10, 37}, {:verb, "to", 10, 38}, {:ws, " ", 10, 40}, {:underscores, "_", 10, 41}, {:verb, "stderr", 10, 42}, {:underscores, "_", 10, 48}, {:period, ".", 10, 49}, {:eol, "", 10, 50},
         {:eol, "", 11, 1},
         {:eol, "", 12, 1}]

      # Toggle the single assert and the looped assert for debugging
        
      assert scan_document(lines) == result

      # scan_document(lines) 
      # |> Enum.zip(result)
      # |> Enum.each( fn {actual, expected} -> assert actual == expected end )
    end
  end
end
