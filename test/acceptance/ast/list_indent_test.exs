defmodule Acceptance.Ast.ListIndentTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1]

  describe "different levels of indent" do

    test "ordered two levels, indented by two" do
      markdown = "1. One\n  2. two"
      html     = "<ol>\n<li><p>One</p>\n<ol start=\"2\">\n<li>two\n</li>\n</ol>\n</li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "mixed two levels (by 2)" do
      markdown = "1. One\n  - two\n  - three"
      html     = "<ol>\n<li><p>One</p>\n<ul>\n<li>two\n</li>\n<li>three\n</li>\n</ul>\n</li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "mixed two levels (by 4)" do
      markdown = "1. One\n    - two\n    - three"
      html     = "<ol>\n<li><p>One</p>\n<ul>\n<li>two\n</li>\n<li>three\n</li>\n</ul>\n</li>\n</ol>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "2 level correct pop up" do
      markdown = "- 1\n  - 1.1\n    - 1.1.1\n  - 1.2"
      html     = "<ul>\n<li><p>1</p>\n<ul>\n<li><p>1.1</p>\n<ul>\n<li>1.1.1\n</li>\n</ul>\n</li>\n<li>1.2\n</li>\n</ul>\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "mixed level correct pop up" do
      markdown = "- 1\n  - 1.1\n      - 1.1.1\n  - 1.2"
      html     = "<ul>\n<li><p>1</p>\n<ul>\n<li><p>1.1</p>\n<ul>\n<li>1.1.1\n</li>\n</ul>\n</li>\n<li>1.2\n</li>\n</ul>\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "4 level correct pop up" do
      markdown = "- 1\n    - 1.1\n        - 1.1.1\n    - 1.2"
      html     = "<ul>\n<li><p>1</p>\n<ul>\n<li><p>1.1</p>\n<ul>\n<li>1.1.1\n</li>\n</ul>\n</li>\n<li>1.2\n</li>\n</ul>\n</li>\n</ul>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
