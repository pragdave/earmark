defmodule Regressions.I88AnchorLinksInsideParensTest do
  use ExUnit.Case

    @tag :wip
    # We sacrifice this esoteric behavior for issue #220 right now
    test "parens: non regression on titles" do
      result = Earmark.as_html!( "[text](link 'title')still title'))" )
      assert ~s{<p><a href="link" title="title&#39;)still title">text</a>)</p>\n} == result
    end


    @tag :wip
    test "parens: images with titles" do
      result = Earmark.as_html!( "![text](src 'title')still title'))" )
      assert ~s{<p><img src="src" alt="text" title="title&#39;)still title"/>)</p>\n} == result
    end
  # end
end

# SPDX-License-Identifier: Apache-2.0
