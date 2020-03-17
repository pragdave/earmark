defmodule Acceptance.Html.AtxHeadersTest do
  use Support.AcceptanceTestCase
  
  describe "ATX headers" do

    test "from one to six" do
      markdown = "# foo\n## foo\n### foo\n#### foo\n##### foo\n###### foo\n"
      html     = gen((1..6)|>Enum.map(&{String.to_atom("h#{&1}"), "foo"}))
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "seven? kidding, right?" do
      markdown = "####### foo"
      html     = para(markdown)
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

    test "some prefer to close their headers" do
      markdown = "# foo#\n"
      html     = gen({:h1, "foo"})
      messages = []

      assert Earmark.as_html(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
