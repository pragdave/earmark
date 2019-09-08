defmodule Acceptance.Html1.AtxHeadersTest do
  use ExUnit.Case, async: true
  
  import Support.Html1Helpers
  
  @moduletag :html1
  describe "ATX headers" do

    test "from one to six" do
      markdown = "# foo\n## foo\n### foo\n#### foo\n##### foo\n###### foo\n"
      html     = Enum.map(1..6, fn x -> ["<h#{x}>\n", "  foo\n", "</h#{x}>\n"] end) |> Enum.join()
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "seven? kidding, right?" do
      markdown = "####### foo\n"
      html     = "<p>\n  ####### foo\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "sticky (better than to have no glue)" do
      markdown = "#5 bolt\n\n#foobar\n"
      html     = "<p>\n  #5 bolt\n</p>\n<p>\n  #foobar\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "close escape" do
      markdown = "\\## foo\n"
      html     = "<p>\n  ## foo\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "position is so important" do
      markdown = "# foo *bar* \\*baz\\*\n"
      html     = "<h1>\n  foo \n  <em>\n    bar\n  </em>\n   *baz*\n</h1>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "spacy" do
      markdown = "#                  foo                     \n"
      html     = "<h1>\n  foo\n</h1>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "code comes first" do
      markdown = "    # foo\nnext"
      html     = "<pre>\n  <code>\n    # foo\n  </code>\n</pre>\n<p>\n  next\n</p>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "some prefer to close their headers" do
      markdown = "# foo#\n"
      html     = "<h1>\n  foo\n</h1>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "yes, they do (prefer closing their header)" do
      markdown = "### foo ### "
      html     = "<h3>\n  foo ###\n</h3>\n"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
