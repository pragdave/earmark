defmodule Regressions.I070AutolinkWithParentheses do
  use ExUnit.Case

  test "Issue https://github.com/pragdave/earmark/issues/70" do
    assert Earmark.to_html(~s{[Wikipedia article on PATH](https://en.wikipedia.org/wiki/PATH_(variable))}) ==
    ~s{<p><a href="https://en.wikipedia.org/wiki/PATH_(variable)">Wikipedia article on PATH</a></p>\n}
  end

end
