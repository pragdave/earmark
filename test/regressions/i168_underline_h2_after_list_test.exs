defmodule Regressions.I168UnderlineH2AfterListTest do
  use ExUnit.Case, async: true

  @h2_underline_vanilla """
  para

  hl2
  ---
  """

  test "underline vanilla underline h2" do
    {:ok, result, []} = Earmark.as_html(@h2_underline_vanilla)
    assert result == "<p>para</p>\n<h2>hl2</h2>\n"
  end

  @h2_underline_after_ul """
  * para

  hl2
  ---
  """
  test "underline after ul" do
    {:ok, result, []} = Earmark.as_html(@h2_underline_after_ul)
    assert result == "<ul>\n<li>para\n</li>\n</ul>\n<h2>hl2</h2>\n"
  end
end

# SPDX-License-Identifier: Apache-2.0
