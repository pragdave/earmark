defmodule Regressions.I041HrIncorrectHtmlTest do
  use ExUnit.Case

  test "https://github.com/pragdave/earmark/issues/41" do
    result = Earmark.to_html "****"
    assert result == ~s[<hr class="thick"/>\n]
  end

end
