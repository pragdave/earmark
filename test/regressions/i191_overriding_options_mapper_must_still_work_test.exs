defmodule Regressions.I191OverridingOptionsMapperMustStillWorkTest do
  use ExUnit.Case

  alias Earmark.Options

  @simple "**hello**"

  test "new implementation works" do
    {:ok, result, []} = Earmark.as_html(@simple, %Options{timeout: 10_000})
    assert result == "<p><strong>hello</strong></p>\n"
  end

  test "timeout is really set" do
    long = (1..5_000)
      |> Enum.map(fn _ -> @simple end)
      |> Enum.join("\n")
    assert_raise(Earmark.Error, ~r{has not responded within the set timeout of 1ms}, fn ->
      Earmark.as_html(long, %Options{timeout: 1})
    end)
  end

  test "users could have done something like the following, so it must still work" do
    {:ok, result, []} = Earmark.as_html(@simple, %Options{mapper: &Enum.map/2})
    assert result == "<p><strong>hello</strong></p>\n"
  end
end
