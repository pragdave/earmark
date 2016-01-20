defmodule RegressionsTest.I012DoctestExceptionTest do
  use ExUnit.Case

  @issue_12 """
    iex> {:ambiguous, am} = Kalends
    {:error, :no_matches}
  """  

  test "Issue https://github.com/pragdave/earmark/issues/12" do
    alias Earmark.Options
    result = catch_error(Earmark.to_html @issue_12, %Options{mapper: &Enum.map/2})
    assert result.message == "Invalid Markdown attributes: {error, :no_matches}"
  end

end
