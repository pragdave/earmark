defmodule Acceptance.Html.ParagraphsTest do
  use Support.AcceptanceTestCase

  describe "Paragraphs" do
    test "a para" do
      markdown = "aaa\n\nbbb\n"
      html     = "<p>\naaa</p>\n<p>\nbbb</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
