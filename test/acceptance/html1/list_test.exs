defmodule Acceptance.Html1.ListTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_html: 1]
  import Support.Html1Helpers
  
  @moduletag :html1

   describe "List items" do
    test "Unnumbered" do
      markdown = "* one\n* two"
      html     = construct(
        {:ul, nil, [
          {:li, nil, "one"},
          {:li, nil, "two"}]})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "Unnumbered Indented" do
      markdown = "  * one\n  * two"
      html     = construct(
        {:ul, nil, [
          {:li, nil, "one"},
          {:li, nil, "two"}]})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "Unnumbered Indent taken into account" do
      markdown = "   * one\n     one.one\n   * two"
      html     = construct(
        {:ul, nil, [
          {:li, nil, "one\none.one"},
          {:li, nil, "two"}]})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "Unnumbered two paras (removed from func tests)" do
      markdown = "* one\n\n    indent1\n"
      html     = construct(
        {:ul, nil,
          {:li, nil, [
            {:p, nil, "one"},
            {:p, nil, "  indent1"}]}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    # Not GFM conformant, >3 goes into the head of the item
    test "Indented items, by 4 (removed from func tests)" do
      markdown = "1. one\n    - two\n        - three"
      html     = construct(
        {:ol, nil,
           {:li, [
             {:p, nil, "one"},
             {:ul, nil,
                {:li, [
                  {:p, nil, "two"},
                  {:ul, {:li, nil, "three"}}]}}]}})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "Numbered" do
      markdown = "1.  A paragraph\n    with two lines.\n\n        indented code\n\n    > A block quote.\n"
      html     = construct(
        {:ol, nil,
          {:li, nil, [
            {:p, nil, "A paragraph\nwith two lines."},
            {:pre, {:code, nil, "indented code"}},
            {:blockquote, {:p, nil, "A block quote."}}]}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "More numbers" do
      markdown = "1.  space one\n\n1. space two"
      html     = construct(
        {:ol, [
          {:li, {:p, nil, "space one"}},
          {:li, {:p, nil, "space two"}}]})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "can't count" do
      markdown = "- one\n\n two\n"
      html     = construct([
        {:ul, nil, {:li, nil, "one"}},
        {:p, nil, " two"}])

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "still not" do
      markdown = "- one\n- two"
      html     = construct(
        {:ul, [{:li, nil, "one"},{:li, nil, "two"}]})
      
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "the second one is not one" do
      markdown = "1. one\n1. two"
      html     = construct(
        {:ol, [
          {:li, nil, "one"},
          {:li, nil, "two"}]})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "where shall we start" do
      markdown = "2. one\n3. two"
      html     = construct(
        {:ol, ~s{start="2"}, [
          {:li, nil, "one"},
          {:li, nil, "two"}]})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "one?" do
      markdown = "2. one"
      html     = construct(
        {:ol, ~s{start="2"}, {:li, nil, "one"}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "count or no count?" do
      markdown = "-one\n\n2.two\n"
      html     = construct([
        {:p, nil, "-one"},
        {:p, nil, "2.two"}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "list or no list?" do
      markdown = "-1. not ok\n"
      html     = para("-1. not ok")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "no count or count?" do
      markdown = "1. foo\nbar"
      html     = construct(
        {:ol, {:li, nil, "foo\nbar"}})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "where does it end?" do
      markdown = "* a\n    b\nc"
      html     = construct(
        {:ul, {:li, nil, "a\n  b\nc"}})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "tables in lists? Maybe not" do
      markdown = "* x\n    a\n| A | B |"
      html     = construct(
        {:ul, {:li, nil, "x\n  a\n| A | B |"}})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "nice try, but naah" do
      markdown = "* x\n | A | B |"
      html     = construct(
        {:ul, {:li, nil, "x\n| A | B |"}})

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "Inline code" do
    @tag :wip
    test "perserves spaces" do
      markdown = "* \\`prefix`first\n*      second \\`\n* third` `suffix`" |> IO.inspect

      html     = "<ul>\n<li><p>`prefix<code class=\"inline\">first * second \\`</code></p>\n<li>third<code class=\"inline\"></code>suffix`\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
