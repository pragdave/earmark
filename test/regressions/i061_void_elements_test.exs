defmodule Regressions.I061VoidElementsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  @i61_void_elements ~s{<img src="whatever.png">}
  test "Issue: https://github.com/pragdave/earmark/issues/61" do
    result = Earmark.to_html @i61_void_elements
    assert result == ~s[<img src="whatever.png">\n]
  end

  test "Issue: https://github.com/pragdave/earmark/issues/61 no message" do
    assert capture_io(:stderr, fn ->
      Earmark.to_html @i61_void_elements
    end) == ""
  end
end
