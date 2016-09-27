defmodule EarmarkHelpersTests.Lookahead.LinkParserTest do
  use ExUnit.Case

  import Earmark.Helpers.LeexHelpers, only: [lex: 2]

  test "empty" do 
    assert {[], '[]'} == parse("[]")
  end

  test "incorrect" do 
    assert nil == parse("([")
    assert nil == parse("([x[]")
  end

  test "simple text" do 
    assert {'hello', '[hello]'} == parse("[hello]")
  end
  test "text with escapes" do 
    str = "[hello\\[]"
    assert {'hello[', String.to_char_list(str)} == parse(str)
  end
  test "text with many parts" do 
    str = "[hello( world\\])]"
    assert {'hello( world])', String.to_char_list(str)} == parse(str)
  end
  test "simple imbrication" do 
    str = "[[hello]]"
    assert {'[hello]', String.to_char_list(str)} == parse(str)
  end
  test "complex imbrication" do 
    str = "[pre[iniside]suff]"
    assert {'pre[iniside]suff', String.to_char_list(str)} == parse(str)
  end
  test "deep imbrication" do 
    str = "[pre[[in\\]]side])]"
    assert {'pre[[in]]side])', String.to_char_list(str)} == parse(str)
  end
  test "with quotes" do
    str = ~s<["hello']>
    assert {'"hello\'', String.to_char_list(str)} == parse(str)
  end
  test "with open_title token" do 
    str = ~s<[hello "world"]>
    assert {'hello "world"', String.to_char_list(str)} == parse(str)
  end
  test "with quotes and escapes" do
    str = ~s<["hell\\o']>
    assert {'"hello\'', String.to_char_list(str)} == parse("#{str}(url\\))")
  end
  test "missing closing brackets" do 
    assert nil ==  parse("[pre[[in\\]side])]")
  end
  test "complex case" do 
    str = "[text](pre](in  fix)suff)"
    assert {'text', '[text]'} == parse(str)
  end
  test "even more complex" do 
    str = "[text](a(1)[((2) \\\\one)z)"
    assert {'text','[text]'} == parse(str)
  end
  test "images" do 
    str = ~s<![f[]oo](/url "ti() tle")>
    assert {'f[]oo', '![f[]oo]'} == parse(str)
  end

  defp parse str do
    case str
    |> lex(with: :link_text_lexer)
    |> :link_text_parser.parse() do
      {:ok, ast} -> ast
      {:error, _} ->
        nil
    end
  end
  
end
