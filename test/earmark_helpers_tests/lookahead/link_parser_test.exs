defmodule EarmarkHelpersTests.Lookahead.LinkParserTest do
  use ExUnit.Case

  import Earmark.Helpers.LeexHelpers, only: [lex: 2]
  describe "text part" do
    test "empty" do 
      assert [] == parse("[]")
    end
    test "incorrect" do 
      assert nil == parse("([]")
    end
    test "simple text" do 
      assert 'hello' == parse("[hello]")
    end
    test "text with escapes" do 
      assert 'hello[' == parse("[hello\\[]")
    end
    test "text with many parts" do 
      assert 'hello( world])' == parse("[hello( world\\])]")
    end
    test "simple imbrication" do 
      assert '[hello]' == parse("[[hello]]")
    end
    test "complex imbrication" do 
      assert 'pre[iniside]suff' == parse("[pre[iniside]suff]")
    end
    test "deep imbrication" do 
      assert 'pre[[in]]side])' == parse("[pre[[in\\]]side])]")
    end
    test "missing closing brackets" do 
      assert nil ==  parse("[pre[[in\\]side])]")
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
