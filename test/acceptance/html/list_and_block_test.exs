defmodule Acceptance.Html.ListAndBlockTest do
  use Support.AcceptanceTestCase

  describe "Block Quotes in Lists" do
    test "four spaces" do
      markdown = "- c\n    > d"
      html     = "<ul>\n  <li>\nc    <blockquote>\n      <p>\nd      </p>\n    </blockquote>\n  </li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
