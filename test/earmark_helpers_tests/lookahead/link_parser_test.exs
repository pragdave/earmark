defmodule EarmarkHelpersTests.Lookahead.LinkParserTest do
  use ExUnit.Case

  import Earmark.Helpers.LeexHelpers, only: [lex: 2]
  describe "text part" do
    test "empty" do 
      assert {'[]()', [], [], nil} == parse("[]()")
    end
    test "incorrect" do 
      assert nil == parse("([]")
      assert nil == parse("([]()")
    end
    test "simple text" do 
      assert {'[hello]()', 'hello', '', nil} == parse("[hello]()")
    end
    test "text with escapes" do 
      assert {'[hello[]()', 'hello[', '', nil} == parse("[hello\\[]()")
    end
    test "text with many parts" do 
      assert {'[hello( world])]()', 'hello( world])', '', nil} == parse("[hello( world\\])]()")
    end
    test "simple imbrication" do 
      assert {'[[hello]]()', '[hello]', '', nil} == parse("[[hello]]()")
    end
    test "complex imbrication" do 
      assert {'[pre[iniside]suff]()', 'pre[iniside]suff', '', nil} == parse("[pre[iniside]suff]()")
    end
    test "deep imbrication" do 
      assert {'[pre[[in]]side])]()', 'pre[[in]]side])', '', nil} == parse("[pre[[in\\]]side])]()")
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
      assert {'[text](url)', 'text', 'url', nil} == parse("[text](url)")
    end
    test "url with escapes" do 
      assert {'[text](url))', 'text', 'url)', nil} == parse("[text](url\\))")
    end
    test "url with many parts" do 
      assert {'[text](pre[()', 'text', 'pre[(', nil} == parse("[text](pre[\\()")
    end
    test "simple imbrication" do 
      assert {'[text]((url))', 'text', '(url)', nil} == parse("[text]((url))")
    end
    test "complex imbrication" do 
      assert {'[text](pre](in fix)suff)', 'text', 'pre](in fix)suff', nil} == parse("[text](pre](in fix)suff)")
    end
    test "deep imbrication" do 
      assert {'[text](a(1)[((2) \\one)z)', 'text', 'a(1)[((2) \\one)z', nil} == parse("[text](a(1)[((2) \\\\one)z)")
    end
    test "missing closing parens" do 
      assert nil ==  parse("[text](")
    end
  end

  describe "url part with title" do
    test "simple url" do 
      assert {'[text](url)', 'text', 'url', 'title'} == parse("[text](url 'title')")
      assert {'[text](url)', 'text', 'url', 'title'} == parse("[text](url'title')")
      assert {'[text](url)', 'text', 'url', 'title'} == parse(~s<[text](url"title")>)
    end

    # FIXME in v2, remove this test
    test "remove in v2" do 
      assert {'[text](url)', 'text', 'url', 'title'} == parse(~s<[text](url "title')>)
      assert {'[text](url)', 'text', 'url', 'title'} == parse(~s<[text](url 'title")>)
    end
    test "simple url w/o title" do 
      assert {'[text](url)', 'text', 'url', nil} == parse("[text](url)")
      assert {'[text](url)', 'text', 'url"title', nil} == parse(~s<[text](url\\"title)>)
    end
    test "title escapes parens" do 
      assert {'[text](url "(title")', 'text', 'url', '(title'} == parse(~s<[text](url "(title")>)
      assert {'[text](url "tit)le")', 'text', 'url', '(title'} == parse(~s<[text](url "tit)le")>)
    end
  end

  describe "complex example" do

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
