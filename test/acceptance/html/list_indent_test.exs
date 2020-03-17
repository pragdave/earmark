defmodule Acceptance.Html.ListIndentTest do
  use Support.AcceptanceTestCase

  describe "different levels of indent" do
    test "ordered two levels, indented by two" do
      markdown = "1. One\n  2. two"
      html     = gen({:ol, [{:li, "One"}, {:li, "two"}]})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
