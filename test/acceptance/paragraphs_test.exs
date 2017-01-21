defmodule Acceptance.ParagraphsTest do
  use ExUnit.Case

  describe "Paragraphs" do
    test "a para" do
      markdown = "aaa\n\nbbb\n"
      html     = "<p>aaa</p>\n<p>bbb</p>\n"
      messages = []

      assert Earmark.as_html(markdown) == {html, messages}
    end

    test "and another one" do
      markdown = "aaa\n\n\nbbb\n"
      html     = "<p>aaa</p>\n<p>bbb</p>\n"
      messages = []

      assert Earmark.as_html(markdown) == {html, messages}
    end

  end
end
