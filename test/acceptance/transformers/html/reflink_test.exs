defmodule Acceptance.Transformers.Html.ReflinkTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "undefined reflinks" do
    test "simple case" do
      markdown = "[text] [reference]\n[reference1]: some_url"
      html     = para("[text] [reference]")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "an image, one would assume..." do
      markdown = "![text] [reference]\n[reference1]: some_url"
      html     = para("![text] [reference]")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "defined reflinks" do
    test "simple case" do
      markdown = "[text] [reference]\n[reference]: some_url"
      html     = para( {:a, ~s{href="some_url" title=""}, "text"} )
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "not so simple case" do
      markdown = "[[]]]text] [reference]\n[reference]: some_url"
      html     = para( {:a, ~s{href="some_url" title=""}, "[]]]text"} )
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "titled case" do
      markdown = "[text] [reference]\n[reference]: some_url 'a title'"
      html     = para( {:a, ~s{href="some_url" title="a title"}, "text"} )
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "image with title" do
      markdown = "![text] [reference]\n[reference]: some_url 'a title'"
      html     = para({:img, ~s{src="some_url" alt="text" title="a title"}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end
