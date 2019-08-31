defmodule Regressions.I017ParsingErrorTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "Issue https://github.com/pragdave/earmark/issues/17" do
    assert capture_io( :stderr, fn->
      Earmark.as_html! "A\nB\n="
    end) == "<no file>:3: warning: Unexpected line =\n"
  end
end

# SPDX-License-Identifier: Apache-2.0
