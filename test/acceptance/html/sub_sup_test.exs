defmodule Acceptance.Html.SubSupTest do
  use Support.AcceptanceTestCase

  describe "sub_sup" do
    test "no sub, no sup" do
      markdown = "a~b~ c^d^"
      html = "<p>\na~b~ c^d^</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "sub and sup" do
      markdown = "a~b~ c^d^"
      html = "<p>\na  <sub>\nb  </sub>\n c  <sup>\nd  </sup>\n</p>\n"
      messages = []

      assert as_html(markdown, sub_sup: true) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
