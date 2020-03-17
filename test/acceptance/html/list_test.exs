defmodule Acceptance.Html.ListTest do
  use Support.AcceptanceTestCase

   describe "List items" do
    test "Unnumbered" do
      markdown = "* one\n* two"
      html     = gen({:ul, [{:li, "one"}, {:li, "two"}]})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "Numbered" do
      markdown = "1.  A paragraph\n    with two lines.\n\n        indented code\n\n    > A block quote.\n"
      html     = gen({:ol, {:li,
        [{:p, " A paragraph\nwith two lines."},
          "<pre><code>indented code</code></pre>",
          {:blockquote, {:p, "A block quote."}}]}})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end

end

# SPDX-License-Identifier: Apache-2.0
