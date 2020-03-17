defmodule Acceptance.Html.ListAndBlockTest do
  use Support.AcceptanceTestCase

  describe "Block Quotes in Lists" do
    test "four spaces" do
      markdown = "- c\n    > d"
      html     = gen({:ul, {:li, ["c", {:blockquote, {:p, "d"}}]}})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
