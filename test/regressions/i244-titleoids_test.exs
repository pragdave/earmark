defmodule Regressions.I244TitleoidsTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1]

  describe "title in a link" do
    test "titled link" do
      markdown = "[link](/uri \"title\")\n"
      html = "<p><a href=\"/uri\" title=\"title\">link</a></p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "titleoids after link" do
    test "title must not come from outside -- double / double" do
      markdown = "The [Foo](/dash \"foo\") page (in \"bar\")\n"
      html     = "<p>The <a href=\"/dash\" title=\"foo\">Foo</a> page (in “bar”)</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "title must not come from outside -- double / single" do
      markdown = "The [Foo](/dash \"foo\") page (in 'bar')\n"
      html     = "<p>The <a href=\"/dash\" title=\"foo\">Foo</a> page (in ‘bar’)</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "title must not come from outside -- single / double" do
      markdown = "The [Foo](/dash 'foo') page (in \"bar\")\n"
      html     = "<p>The <a href=\"/dash\" title=\"foo\">Foo</a> page (in “bar”)</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "title must not come from outside -- single / single " do
      markdown = "The [Foo](/dash 'foo') page (in 'bar')\n"
      html     = "<p>The <a href=\"/dash\" title=\"foo\">Foo</a> page (in ‘bar’)</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

end
