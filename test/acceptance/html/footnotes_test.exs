defmodule Acceptance.Html.FootnotesTest do
  use Support.AcceptanceTestCase

  describe "Footnotes" do
    test "without errors" do
      markdown = "foo[^1] again\n\n[^1]: bar baz"
      html     = [ 
        ~s{<p>},
        ~s{  foo},
        ~s{  <a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">},
        ~s{    1},
        ~s{  </a>},
        ~s{   again},
        ~s{</p>}, 
        ~s{<div class="footnotes">}, 
        ~s{  <hr />}, 
        ~s{  <ol>}, 
        ~s{    <li id="fn:1">},
        ~s{      <p>},
        ~s{        bar baz},
        ~s{        <a class="reversefootnote" href="#fnref:1" title="return to article">},
        ~s{          &#x21A9;},
        ~s{        </a>},
        ~s{      </p>}, 
        ~s{    </li>}, 
        ~s{  </ol>}, 
        ~s{</div>\n} ] |> Enum.join("\n")
      messages = []

      assert as_html(markdown, footnotes: true) == {:ok, html, messages}
    end
  end
  
end

# SPDX-License-Identifier: Apache-2.0
