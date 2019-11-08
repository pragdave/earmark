defmodule Acceptance.Html.ListAndBlockTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_html: 1]

  describe "Block Quotes in Lists" do
    # Incorrect behavior needs to be fixed with #249 or #304
    test "two spaces" do
      markdown = "- a\n  > b"
      html     = "<ul>\n<li>a\n</li>\n</ul>\n<blockquote><p>b</p>\n</blockquote>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "four spaces" do
      markdown = "- c\n    > d"
      html     = "<ul>\n<li><p>c</p>\n<blockquote><p>d</p>\n</blockquote>\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
