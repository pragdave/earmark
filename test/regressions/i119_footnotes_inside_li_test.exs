defmodule Regressions.I119FootnotesInsideLiTest do
  use ExUnit.Case
  
  @li_footnote """
  1. foo[^1]
  
  [^1]: bar baz
  """
  test "footnotes in list items do not crash (no footnotes)" do
    assert without_fn(@li_footnote) == {:ok,~s{<ol>\n<li>foo[^1]\n</li>\n</ol>\n<p>[^1]: bar baz</p>\n}, []}
  end

  test "footnotes in list items do not crash (footnotes)" do
    assert with_fn(@li_footnote) == {:ok,
      ~s{<ol>\n<li>foo<a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">1</a>\n</li>\n</ol>\n<div class=\"footnotes\">\n<hr>\n<ol>\n<li id=\"fn:1\"><p>bar baz&nbsp;<a href=\"#fnref:1\" title=\"return to article\" class=\"reversefootnote\">&#x21A9;</a></p>\n</li>\n</ol>\n\n</div>},
      []}
  end

  defp with_fn(md), do: Earmark.as_html(md, %Earmark.Options{footnotes: true})
  defp without_fn(md), do: Earmark.as_html(md, %Earmark.Options{footnotes: false})
end
