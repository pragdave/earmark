defmodule Acceptance.Html.ReflinkTest do
  use Support.AcceptanceTestCase

  describe "undefined reflinks" do
    test "simple case" do
      markdown = "[text] [reference]\n[reference1]: some_url"
      html     = "<p>\n[text] [reference]</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "defined reflinks" do
    test "simple case" do
      markdown = "[text] [reference]\n[reference]: some_url"
      html     = "<p>\n<a href=\"some_url\" title=\"\">text</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "image with title" do
      markdown = "![text] [reference]\n[reference]: some_url 'a title'"
      html     = para({:img, [src: "some_url", alt: "text", title: "a title"], nil})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end
