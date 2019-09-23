defmodule Acceptance.Html1.ParagraphsTest do
  use ExUnit.Case, async: true
  
  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Paragraphs" do
    test "a para" do
      markdown = "aaa\n\nbbb\n"
      html     = construct([:p, "aaa", :POP, :p, "bbb"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "and another one" do
      markdown = "aaa\n\n\nbbb\n"
      html     = construct([:p, "aaa", :POP, :p, "bbb"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end


    test "striketrhough" do
      markdown = "~~or maybe not?~~"
      html     = para({:del, nil, "or maybe not?"})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
