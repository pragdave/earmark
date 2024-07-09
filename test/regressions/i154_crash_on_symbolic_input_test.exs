defmodule Test.Regressions.I154CrashOnSymbolicInputTest do
  use ExUnit.Case

  test "do not crash here" do
    md = "\\[{:}"
    html = "<p>[</p>"
    assert Earmark.as_html(md) == html
  end
  
end
# SPDX-License-Identifier: Apache-2.0
