defmodule Regressions.I191OverridingOptionsMapperMustStillWorkTest do
  use ExUnit.Case

  alias Earmark.Options

  @simple "**hello**"

  test "new implementation works" do
    {:ok, result, []} = Earmark.as_html(@simple)
    assert result == "<p><strong>hello</strong></p>\n"
  end

  test "users could have done something like the following, so it must still work" do
    {:ok, result, []} = Earmark.as_html(@simple, %Options{mapper: &Enum.map/2})
    assert result == "<p><strong>hello</strong></p>\n"
  end
end
