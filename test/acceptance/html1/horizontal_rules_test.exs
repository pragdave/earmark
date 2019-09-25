defmodule Acceptance.Html1.HorizontalRulesTest do
  use ExUnit.Case, async: true
  
  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Horizontal rules" do

    test "thick, thin & medium" do
      markdown = "***\n---\n___\n"
      html     = construct([
        {:hr, ~s{class="thick"}},
        {:hr, ~s{class="thin"}},
        {:hr, ~s{class="medium"}}])

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "not a rule" do
      markdown = "+++"
      html     = para("+++")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "still not a rule" do
      markdown = "+++\n"
      html     = para("+++")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end


    test "not in code" do
      markdown = "    ***\n    \n     a"
      html     = "<pre><code>***\n\n a</code></pre>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "not in code, second line" do
      markdown = "Foo\n    ***\n"
      html     = construct([
        {:p, nil, "Foo"},
        "<pre><code>***</code></pre>"
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "medium, long" do
      markdown = "_____________________________________\n"
      html     = construct({:hr, ~s{class="medium"}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "emmed, so to speak" do
      markdown = " *-*\n"
      html     = construct(
        {:p, nil, [" ", {:em, nil, "-"}]})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "in lists" do
      markdown = "- foo\n***\n- bar\n"
      html     = construct([
        {:ul, nil, {:li, nil, "foo"}},
        {:hr, ~s{class="thick"}},
        {:ul, nil, {:li, nil, "bar"}}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "setext rules over rules (why am I soo witty?)" do
      markdown = "Foo\n---\nbar\n"
      html     = construct([
        {:h2, nil, "Foo"},
        {:p, nil, "bar"}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "in lists, thick this time (why am I soo good to you?)" do
      markdown = "* Foo\n* * *\n* Bar\n"
      html     = construct([
        {:ul, nil, {:li, nil, "Foo"}},
        {:hr, ~s{class="thick"}},
        {:ul, nil, {:li, nil, "Bar"}}])
      messages = []
      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "Horizontal Rules and IAL" do 
    test "add a class and an id" do
      markdown = "***\n{: .custom}\n---\n{: .klass #id42}\n___\n"
      html     = construct([
        {:hr, ~s{class="custom thick"}},
        {:hr, ~s{class="klass thin" id="id42"}},
        {:hr, ~s{class="medium"}}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    
  end
end

# SPDX-License-Identifier: Apache-2.0
