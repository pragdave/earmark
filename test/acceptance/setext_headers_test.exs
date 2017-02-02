defmodule Acceptance.SetextHeadersTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_html: 1]

  # describe "Setext headers" do

    test "levels one and two" do
      markdown = "Foo *bar*\n=========\n\nFoo *bar*\n---------\n"
      html     = "<h1>Foo <em>bar</em></h1>\n<h2>Foo <em>bar</em></h2>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "and levels two and one" do
      markdown = "Foo\n-------------------------\n\nFoo\n=\n"
      html     = "<h2>Foo</h2>\n<h1>Foo</h1>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "narrow escape" do
      markdown = "Foo\\\n----\n"
      html = "<h2>Foo\\</h2>\n"
      messages = []
      assert as_html(markdown) == {:ok, html, messages}
    end

  # end
  # There is no consensus on this one, I prefer to not define the behavior of this unless
  # there is a real use case
  # c.f. http://johnmacfarlane.net/babelmark2/?text=%60Foo%0A----%0A%60%0A%0A%3Ca+title%3D%22a+lot%0A---%0Aof+dashes%22%2F%3E%0A
  #    html = "<h2>`Foo</h2>\n<p>`</p>\n<h2>&lt;a title=&quot;a lot</h2>\n<p>of dashes&quot;/&gt;</p>\n"
  #    markdown = "`Foo\n----\n`\n\n<a title=\"a lot\n---\nof dashes\"/>\n"
end
