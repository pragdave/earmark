defmodule Acceptance.Html.AtxHeadersTest do
  use Support.AcceptanceTestCase
  
  describe "ATX headers" do

    test "from one to six" do
      markdown = "# foo\n## foo\n### foo\n#### foo\n##### foo\n###### foo\n"
      html     = "<h1>\nfoo</h1>\n<h2>\nfoo</h2>\n<h3>\nfoo</h3>\n<h4>\nfoo</h4>\n<h5>\nfoo</h5>\n<h6>\nfoo</h6>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "seven? kidding, right?" do
      markdown = "####### foo"
      html     = "<p>\n####### foo</p>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "some prefer to close their headers" do
      markdown = "# foo#\n"
      html     = "<h1>\nfoo</h1>\n"
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
