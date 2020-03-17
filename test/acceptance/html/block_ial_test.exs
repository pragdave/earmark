defmodule Acceptance.Html.BlockIalTest do
  use Support.AcceptanceTestCase

   describe "IAL" do
    test "Not associated" do
      markdown = "{:hello=world}"
      html     = para(markdown)
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "Not associated means verbatim" do
      markdown = "{: hello=world  }"
      html     = para(markdown)
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "Associated" do
      markdown = "Before\n{:hello=world}"
      html     = gen({:p, [hello: "world"], "Before"})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
