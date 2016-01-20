defmodule Regressions.I030BacktixInHeadingsTest do
  use ExUnit.Case

  @heading_inline_render """
  # Hello _World_
  """
  test "Issue https://github.com/pragdave/earmark/issues/30" do
    result = Earmark.to_html @heading_inline_render
    assert result == """
                     <h1>Hello <em>World</em></h1>
                     """
  end

end
