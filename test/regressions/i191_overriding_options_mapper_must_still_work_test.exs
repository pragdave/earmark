defmodule Regressions.I191OverridingOptionsMapperMustStillWorkTest do
  use ExUnit.Case, async: true 

  alias Earmark.Options

  @simple "**hello**"
  @result "<p>\n  <strong>\n    hello\n  </strong>\n</p>\n"

  describe "no timeout" do
    test "new implementation works" do
      {:ok, result, []} = Earmark.as_html("**hello**", %Options{timeout: 10_000})
      assert result == @result
    end

    test "users could have done something like the following, so it must still work" do
      {:ok, result, []} = Earmark.as_html(@simple, %Options{mapper: &Enum.map/2})
      assert result == @result
    end
  end

end
