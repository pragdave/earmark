defmodule Regressions.I017ParsingErrorTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  test "Issue https://github.com/pragdave/earmark/issues/17" do
    assert capture_io( :stderr, fn->
      Earmark.to_html "A\nB\n="
    end) == "Unexpected line =\n"
  end
end
