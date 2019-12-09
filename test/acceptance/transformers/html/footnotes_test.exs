defmodule Acceptance.Transformers.Html.FootnotesTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Footnotes" do

    test "without errors" do
      markdown = "foo[^1] again\n\n[^1]: bar baz"

      para =
        {:p, nil, ["foo",
                  {:a, ~s{href="#fn:1" id="fnref:1" class="footnote" title="see footnote"}, ~w{1}},
                  " again"]}
      li = {:li, ~s{id="fn:1"},
                   [:p, 
                    "bar baz", 
                    {:a, ~s{class="reversefootnote" href="#fnref:1" title="return to article"}, ~w{↩}}
                   ]
                 }
      html     = construct([
        para,
        {:div, 
           ~s{class="footnotes"},
           [ 
             :hr,
             :ol,
             li]}])
      messages = []

      assert to_html1(markdown, footnotes: true) == {:ok, html, messages}
    end

    test "undefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^2]: bar baz"
      html     = para("foo[^1]\nhello")
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert to_html1(markdown, footnotes: true) == {:error, html, messages}
    end

    test "undefined footnotes (none at all)" do
      markdown = "foo[^1]\nhello"
      html     = para("foo[^1]\nhello")
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert to_html1(markdown, footnotes: true) == {:error, html, messages}
    end

    test "illdefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^1]:bar baz"
      html     = construct([
        {:p, nil, "foo[^1]\nhello"},
        {:p, nil, "[^1]:bar baz"} ])
      messages = [
        {:error, 1, "footnote 1 undefined, reference to it ignored"},
        {:error, 4, "footnote 1 undefined, reference to it ignored"}]

      assert to_html1(markdown, footnotes: true) == {:error, html, messages}
    end


  end
  
end

# SPDX-License-Identifier: Apache-2.0
