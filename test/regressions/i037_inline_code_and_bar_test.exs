defmodule Regressions.I037InlineCodeAndBarTest do
  use ExUnit.Case

  @implicit_list_with_bar """
  - alpha
  beta | gamma
  """
  test "Issue https://github.com/pragdave/earmark/issues/37" do
    result = Earmark.to_html @implicit_list_with_bar
    assert result == """
                     <ul>
                     <li>alpha\nbeta | gamma
                     </li>
                     </ul>
                     """
  end
end
