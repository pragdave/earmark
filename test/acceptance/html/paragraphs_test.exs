defmodule Acceptance.Html.ParagraphsTest do
  use Support.AcceptanceTestCase

  describe "Paragraphs" do
    test "a para" do
      markdown = "aaa\n\nbbb\n"
      html     = gen([{:p, "aaa"}, {:p, "bbb"}])
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
