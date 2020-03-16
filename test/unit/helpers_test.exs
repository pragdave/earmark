defmodule HelpersTest do
  use ExUnit.Case, async: true
  import Earmark.Helpers

  @moduletag :dev

  test "expand_tab spaces only" do
    assert expand_tabs("   ") == "   "
  end

  test "expand_tab tabs only" do
    assert expand_tabs("\t\t") == "        "
  end

  test "expand_tab mixed" do
    assert expand_tabs(" \t ") == "     "
  end

end

# SPDX-License-Identifier: Apache-2.0
