defmodule EarmarkHelpersTests.KludgeTest do
  use ExUnit.Case

  alias Earmerk.Helpers.Kludge

  describe "text part" do
    test "empty" do 
      assert {~s<[]()>, [], [], nil} == Kludge.parse_link("[]()")
    end
    test "incorrect" do 
      assert nil == Kludge.parse_link("([]")
      assert nil == Kludge.parse_link("([]()")
    end
    test "simple text" do 
      assert {~s<[hello]()>, ~s<hello>, ~s<>, nil} == Kludge.parse_link("[hello]()")
    end
    test "text with escapes" do 
      assert {~s<[hello[]()>, ~s<hello[>, ~s<>, nil} == Kludge.parse_link("[hello\\[]()")
    end
    test "text with many parts" do 
      assert {~s<[hello( world])]()>, ~s<hello( world])>, ~s<>, nil} == Kludge.parse_link("[hello( world\\])]()")
    end
    test "simple imbrication" do 
      assert {~s<[[hello]]()>, ~s<[hello]>, ~s<>, nil} == Kludge.parse_link("[[hello]]()")
    end
    test "complex imbrication" do 
      assert {~s<[pre[iniside]suff]()>, ~s<pre[iniside]suff>, ~s<>, nil} == Kludge.parse_link("[pre[iniside]suff]()")
    end
    test "deep imbrication" do 
      assert {~s<[pre[[in]]side])]()>, ~s<pre[[in]]side])>, ~s<>, nil} == Kludge.parse_link("[pre[[in\\]]side])]()")
    end
    test "missing closing brackets" do 
      assert nil ==  Kludge.parse_link("[pre[[in\\]side])]")
    end
  end

  describe "url part" do
    test "incorrect" do 
      assert nil == Kludge.parse_link("[](")
      assert nil == Kludge.parse_link("[text](url")
    end
    test "simple url" do 
      assert {~s<[text](url)>, ~s<text>, ~s<url>, nil} == Kludge.parse_link("[text](url)")
    end
    test "url with escapes" do 
      assert {~s<[text](url))>, ~s<text>, ~s<url)>, nil} == Kludge.parse_link("[text](url\\))")
    end
    test "url with many parts" do 
      assert {~s<[text](pre[()>, ~s<text>, ~s<pre[(>, nil} == Kludge.parse_link("[text](pre[\\()")
    end
    test "simple imbrication" do 
      assert {~s<[text]((url))>, ~s<text>, ~s<(url)>, nil} == Kludge.parse_link("[text]((url))")
    end
    test "complex imbrication" do 
      assert {~s<[text](pre](in fix)suff)>, ~s<text>, ~s<pre](in fix)suff>, nil} == Kludge.parse_link("[text](pre](in fix)suff)")
    end
    test "deep imbrication" do 
      assert {~s<[text](a(1)[((2) \\one)z)>, ~s<text>, ~s<a(1)[((2) \\one)z>, nil} == Kludge.parse_link("[text](a(1)[((2) \\\\one)z)")
    end
    test "missing closing parens" do 
      assert nil ==  Kludge.parse_link("[text](")
    end
  end

  describe "url part with title" do
    test "simple url" do 
      assert {~s<[text](url)>, ~s<text>, ~s<url>, ~s<title>} == Kludge.parse_link("[text](url 'title')")
      assert {~s<[text](url)>, ~s<text>, ~s<url>, ~s<title>} == Kludge.parse_link("[text](url'title')")
      assert {~s<[text](url)>, ~s<text>, ~s<url>, ~s<title>} == Kludge.parse_link(~s<[text](url"title")>)
    end

    # FIXME in v1.2, remove this test
    test "remove in v2" do 
      assert {~s<[text](url)>, ~s<text>, ~s<url>, ~s<title>} == Kludge.parse_link(~s<[text](url "title')>)
      assert {~s<[text](url)>, ~s<text>, ~s<url>, ~s<title>} == Kludge.parse_link(~s<[text](url 'title")>)
      assert {~s<[text](url)>, ~s<text>, ~s<url>, ~s<title')title")title>} == Kludge.parse_link(~s<[text](url 'title')title")title")>)
    end
    test "simple url w/o title" do 
      assert {~s<[text](url)>, ~s<text>, ~s<url>, nil} == Kludge.parse_link("[text](url)")
      assert {~s<[text](url)>, ~s<text>, ~s<url"title>, nil} == Kludge.parse_link(~s<[text](url\\"title)>)
    end
    test "title escapes parens" do 
      assert {~s<[text](url "(title")>, ~s<text>, ~s<url>, ~s<(title>} == Kludge.parse_link(~s<[text](url "(title")>)
      assert {~s<[text](url "tit)le")>, ~s<text>, ~s<url>, ~s<(title>} == Kludge.parse_link(~s<[text](url "tit)le")>)
    end
  end

  describe "complex example" do

  end
  
end
