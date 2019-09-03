defmodule EarmarkHelpersTests.LinkParserTest do
  use ExUnit.Case, async: true

  describe "text part" do
    test "text part: empty" do
      assert parse_link("[]()") == {~s<[]()>, "", "", nil, :link}
    end

    test "text part: incorrect" do
      assert nil == parse_link("([]")
      assert nil == parse_link("([]()")
    end

    test "text part: simple text" do
      assert parse_link("[hello]()") == {~s<[hello]()>, ~s<hello>, ~s<>, nil, :link}
    end

    test "text part: simple imbrication" do
      assert parse_link("[[hello]]()") == {~s<[[hello]]()>, ~s<[hello]>, ~s<>, nil, :link}
    end

    test "text part: complex imbrication" do
      assert parse_link("[pre[iniside]suff]()") == {~s<[pre[iniside]suff]()>, ~s<pre[iniside]suff>, ~s<>, nil, :link}
    end

    test "text part: missing closing brackets" do
      assert nil == parse_link("[pre[[in\\]side])]")
    end
  end

  describe "url part" do
    test "url part: incorrect" do
      assert nil == parse_link("[](")
      assert nil == parse_link("[text](url")
    end

    test "url part: simple url" do
      assert parse_link("[text](url)") == {~s<[text](url)>, ~s<text>, ~s<url>, nil, :link}
    end

    test "url part: url with escapes" do
      assert parse_link("[text](url\\))") == {~s<[text](url))>, ~s<text>, ~s<url)>, nil, :link}
    end

    test "url part: double )) at end" do
      assert parse_link("[text](url))") == {~s<[text](url)>, ~s<text>, ~s<url>, nil, :link}
    end

    test "url part: url with many parts" do
      assert parse_link("[text](pre[\\()") == {~s<[text](pre[()>, ~s<text>, ~s<pre[(>, nil, :link}
    end

    test "url part: simple imbrication" do
      assert parse_link("[text]((url))") == {~s<[text]((url))>, ~s<text>, ~s<(url)>, nil, :link}
    end

    test "url part: complex imbrication" do
      assert parse_link("[text](pre](in fix)suff)") == {~s<[text](pre](in fix)suff)>, ~s<text>, ~s<pre](in fix)suff>, nil, :link}
    end

    test "url part: deep imbrication" do
      assert parse_link("[text](a(1)[((2) \\\\one)z)") == {~s<[text](a(1)[((2) \\one)z)>, ~s<text>, ~s<a(1)[((2) \\one)z>, nil, :link}
    end

    test "url part: simple, text part: escapes" do
      assert parse_link("[hello \\*world\\*](url)") == {~s<[hello \\*world\\*](url)>, ~s<hello \\*world\\*>, ~s<url>, nil, :link}
    end

    test "url part: missing closing parens" do
      assert nil == parse_link("[text](")
    end
  end

  describe "url part with title" do
    test "url part with title: simple url (single quotes)" do
      assert parse_link("[text](url 'title')") == {~s<[text](url 'title')>, ~s<text>, ~s<url>, ~s<title>, :link}
    end

    test "url part with title: simple url (double quotes)" do
      assert parse_link(~s<[text](url  "title")>) == {~s<[text](url  "title")>, ~s<text>, ~s<url>, ~s<title>, :link}
    end

    test "url part with title: title escapes parens" do
      assert parse_link(~s<[text](url "(title")>) == {~s<[text](url "(title")>, ~s<text>, ~s<url>, ~s<(title>, :link}
    end

    test "url part with title: title escapes parens and suffix" do
      assert parse_link(~s<[text](url "tit)le")>) == {~s<[text](url "tit)le")>, ~s<text>, ~s<url>, ~s<tit)le>, :link}
    end
  end

  # describe "deprecate in v1.2, remove in v1.3" do
  #   test "deprecated:  remove in v1.3" do
  #     assert {~s<[text](url "title')>, ~s<text>, ~s<url "title'>, nil, []} ==
  #              parse_link(~s<[text](url "title')>)

  #     assert {~s<[text](url 'title")>, ~s<text>, ~s<url 'title">, nil, []} ==
  #              parse_link(~s<[text](url 'title")>)

  #     src = ~s<[text](url 'title')title")title")>

  #     assert {~s<[text](url 'title')>, ~s<text>, "url", "title", []} ==
  #              parse_link(src)
  #   end

  #   test "deprecated:  title quotes cannot be escaped" do
  #     assert parse_link(~s<[text](url "title')>) == 
  #       {~s<[text](url "title')>, ~s<text>, ~s<url "title'>, nil, []}

  #     assert parse_link(~s<[text](url 'title\\")>) ==
  #       {~s<[text](url 'title")>, ~s<text>, ~s<url 'title">, nil, []}
  #   end
  # end

  describe "url no title" do
    test "url no title: missing space (single quotes)" do
      assert parse_link("[text](url'title')") == {~s<[text](url'title')>, ~s<text>, ~s<url'title'>, nil, :link}
    end

    test "url no title: missing space (double quotes)" do
      assert parse_link(~s<[text](url"title")>) == {~s<[text](url"title")>, ~s<text>, ~s<url"title">, nil, :link}
    end

    test "url no title: no title even before v1.2" do
      assert parse_link(~s<[text](url"title')>) == {~s<[text](url"title')>, ~s<text>, ~s<url"title'>, nil, :link}
    end

    test "url no title: no title even before v1.2, quotes inversed" do
      assert parse_link(~s<[text](url'title")>) == {~s<[text](url'title")>, ~s<text>, ~s<url'title">, nil, :link}
    end

    test "url no title: missing second quote" do
      assert parse_link(~s<[text](url "title)>) == {~s<[text](url "title)>, ~s<text>, ~s<url "title>, nil, :link}
    end
  end

  describe "images" do
    test "finally!!!" do
      assert parse_link("![text](pre[\\()") == {~s<![text](pre[()>, ~s<text>, ~s<pre[(>, nil, :image}
    end
    test "and with leading spaces" do
      assert parse_link(" ![text](pre[\\()") == {~s< ![text](pre[()>, ~s<text>, ~s<pre[(>, nil, :image}
    end
  end
  defp parse_link(markdown) do
    Earmark.Helpers.LinkParser.parse_link(markdown, 0)
  end
end

# SPDX-License-Identifier: Apache-2.0
