defmodule Test.Regressions.I154CrashOnSymbolicInputTest do
  use ExUnit.Case

  test "do not crash here" do
    md = "\\[{:}"
    html = "<p>\n[{:}</p>\n"
    assert Earmark.as_html(md) == {:ok, html, []}
  end
  
end
# SPDX-License-Identifier: Apache-2.0
