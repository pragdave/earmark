defmodule EarmarkHelpersTests.Lookahead.LinkParserTest do
  use ExUnit.Case

  import Earmark.Helpers.LeexHelpers, only: [lex: 2]
  describe "text part" do
    test "empty" do 
      assert {'[]()', [], []} == parse("[]()")
    end
    test "incorrect" do 
      assert nil == parse("([]")
      assert nil == parse("([]()")
    end
    test "simple text" do 
      assert {'[hello]()', 'hello', ''} == parse("[hello]()")
    end
    test "text with escapes" do 
      assert {'[hello[]()', 'hello[', ''} == parse("[hello\\[]()")
    end
    test "text with many parts" do 
      assert {'[hello( world])]()', 'hello( world])', ''} == parse("[hello( world\\])]()")
    end
    test "simple imbrication" do 
      assert {'[[hello]]()', '[hello]', ''} == parse("[[hello]]()")
    end
    test "complex imbrication" do 
      assert {'[pre[iniside]suff]()', 'pre[iniside]suff', ''} == parse("[pre[iniside]suff]()")
    end
    test "deep imbrication" do 
      assert {'[pre[[in]]side])]()', 'pre[[in]]side])', ''} == parse("[pre[[in\\]]side])]()")
    end
    test "missing closing brackets" do 
      assert nil ==  parse("[pre[[in\\]side])]")
    end
  end

  describe "url part" do
    test "incorrect" do 
      assert nil == parse("[](")
      assert nil == parse("[text](url")
    end
    test "simple url" do 
      assert {'[text](url)', 'text', 'url'} == parse("[text](url)")
    end
    test "url with escapes" do 
      assert {'[text](url))', 'text', 'url)'} == parse("[text](url\\))")
    end
    test "url with many parts" do 
      assert {'[text](pre[()', 'text', 'pre[('} == parse("[text](pre[\\()")
    end
    test "simple imbrication" do 
      assert {'[text]((url))', 'text', '(url)'} == parse("[text]((url))")
    end
    test "complex imbrication" do 
      assert {'[text](pre](in fix)suff)', 'text', 'pre](in fix)suff'} == parse("[text](pre](in fix)suff)")
    end
    test "deep imbrication" do 
      assert {'[text](a(1)[((2) \\one)z)', 'text', 'a(1)[((2) \\one)z'} == parse("[text](a(1)[((2) \\\\one)z)")
    end
    test "missing closing parens" do 
      assert nil ==  parse("[text](")
    end

  end

  defp parse str do
    case str
    |> lex(with: :link_lexer)
    |> :link_parser.parse() do
      {:ok, ast} -> ast
      {:error, e} ->
        # IO.inspect(e)
        nil
    end
  end
  
end
