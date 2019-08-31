defmodule Regressions.I030BacktixInHeadingsTest do
  use ExUnit.Case, async: true

  @heading_inline_render """
  # Hello _World_
  """
  test "Issue https://github.com/pragdave/earmark/issues/30" do
    result = Earmark.as_html! @heading_inline_render
    assert result == """
                     <h1>Hello <em>World</em></h1>
                     """
  end

end

# SPDX-License-Identifier: Apache-2.0
