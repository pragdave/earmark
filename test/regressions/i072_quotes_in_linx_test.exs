defmodule Regressions.I072QuotesInLinx do
  use ExUnit.Case

  test "Issue https://github.com/pragdave/earmark/issues/72" do
    # assert Earmark.as_html!(~s{"Earmark"}) ==
    # ~s{<p>“Earmark”</p>\n}
    assert Earmark.as_html!(~s{["Earmark"](https://github.com/pragdave/earmark/)}) ==
    ~s{<p><a href="https://github.com/pragdave/earmark/">“Earmark”</a></p>\n}
  end

end
