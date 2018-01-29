defmodule Regressions.I139GfmHardBreaksTest do
  use ExUnit.Case

  test "hardlinebreak" do 
    assert {:ok, "<p>a<br/>\nb</p>\n", []} == Earmark.as_html("a\\\nb")
  end

  test "only in gfm" do
    assert {:ok, "<p>a\\\nb</p>\n", []} == Earmark.as_html("a\\\nb", %Earmark.Options{gfm: false})
  end

  test "hardlinebreak and §" do 
    assert {:ok, "<p>a\\</p>\n<p>b</p>\n", []} == Earmark.as_html("a\\\n\nb")
  end
end

# SPDX-License-Identifier: Apache-2.0
