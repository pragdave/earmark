defmodule Regressions.I040UnescpaedLtAndHtmlTest do
  use ExUnit.Case, async: true
  @not_the_first_you_see "<alpha<beta></beta>"
  test "Issue https://github.com/pragdave/earmark/issues/40" do
    result = Earmark.as_html! @not_the_first_you_see
    assert result == "<p>&lt;alpha<beta></beta></p>\n"
  end

end

# SPDX-License-Identifier: Apache-2.0
