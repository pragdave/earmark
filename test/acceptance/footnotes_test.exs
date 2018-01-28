defmodule Acceptance.FootnotesTest do
  use ExUnit.Case

  import Support.Helpers, only: [ as_html: 2]

  # describe "Footnotes" do

    test "without errors" do
      markdown = "foo[^1] again\n\n[^1]: bar baz"
      html     = ~s{<p>foo<a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">1</a> again</p>\n<div class="footnotes">\n<hr>\n<ol>\n<li id="fn:1"><p>bar baz&nbsp;<a href="#fnref:1" title="return to article" class="reversefootnote">&#x21A9;</a></p>\n</li>\n</ol>\n\n</div>}
      messages = []

      assert as_html(markdown, footnotes: true) == {:ok, html, messages}
    end

    test "undefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^2]: bar baz"
      html     = ~s{<p>foo[^1]\nhello</p>\n}
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_html(markdown, footnotes: true) == {:error, html, messages}
    end

    test "undefined footnotes (none at all)" do
      markdown = "foo[^1]\nhello"
      html     = ~s{<p>foo[^1]\nhello</p>\n}
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_html(markdown, footnotes: true) == {:error, html, messages}
    end

    test "illdefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^1]:bar baz"
      html     = ~s{<p>foo[^1]\nhello</p>\n<p>[^1]:bar baz</p>\n}
      messages = [
        {:error, 1, "footnote 1 undefined, reference to it ignored"},
        {:error, 4, "footnote 1 undefined, reference to it ignored"}]

      assert as_html(markdown, footnotes: true) == {:error, html, messages}
    end


  # end
  
end

# SPDX-License-Identifier: Apache-2.0
