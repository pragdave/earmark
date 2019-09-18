defmodule Acceptance.Html1.ReflinkTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_html: 1]

  describe "undefined reflinks" do
    test "simple case" do
      markdown = "[text] [reference]\n[reference1]: some_url"
      html     = "<p>[text] [reference]</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "an image, one would assume..." do
      markdown = "![text] [reference]\n[reference1]: some_url"
      html     = "<p>![text] [reference]</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "defined reflinks" do
    test "simple case" do
      markdown = "[text] [reference]\n[reference]: some_url"
      html     = "<p><a href=\"some_url\" title=\"\">text</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "not so simple case" do
      markdown = "[[]]]text] [reference]\n[reference]: some_url"
      html     = "<p><a href=\"some_url\" title=\"\">[]]]text</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "titled case" do
      markdown = "[text] [reference]\n[reference]: some_url 'a title'"
      html     = "<p><a href=\"some_url\" title=\"a title\">text</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "image with title" do
      markdown = "![text] [reference]\n[reference]: some_url 'a title'"
      html     = "<p><img src=\"some_url\" alt=\"text\" title=\"a title\" /></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end