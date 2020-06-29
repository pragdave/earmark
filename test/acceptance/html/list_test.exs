defmodule Acceptance.Html.ListTest do
  use Support.AcceptanceTestCase

   describe "List items" do
    test "Unnumbered" do
      markdown = "* one\n* two"
      html     = "<ul>\n  <li>\none  </li>\n  <li>\ntwo  </li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "Numbered" do
      markdown = "1.  A paragraph\n    with two lines.\n\n        indented code\n\n    > A block quote.\n"
      html     = "<ol>\n  <li>\n    <p>\n A paragraph\nwith two lines.    </p>\n    <pre><code>indented code</code></pre>\n    <blockquote>\n      <p>\nA block quote.      </p>\n    </blockquote>\n  </li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end

end

# SPDX-License-Identifier: Apache-2.0
