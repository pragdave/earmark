defmodule Regressions.I040UnescpaedLtAndHtmlTest do
  use ExUnit.Case
  @not_the_first_you_see "<alpha<beta></beta>"
  test "Issue https://github.com/pragdave/earmark/issues/40" do
    result = Earmark.to_html @not_the_first_you_see
    assert result == "<p>&lt;alpha<beta></beta></p>\n"
  end

end
