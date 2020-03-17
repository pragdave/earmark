defmodule Acceptance.Html.SetextHeadersTest do
  use Support.AcceptanceTestCase

  describe "Base cases" do

    test "Level one" do 
      markdown = "foo\n==="
      html     = gen({:h1, "foo"})
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end

  describe "Combinations" do

    test "levels one and two" do
      markdown = "Foo *bar*\n=========\n\nFoo *bar*\n---------\n"
      html     = gen([{:h1, ["Foo ", {:em, "bar"}]}, 
        {:h2, ["Foo ", {:em, "bar"}]}])
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  end
  # There is no consensus on this one, I prefer to not define the behavior of this unless
  # there is a real use case
  # c.f. http://johnmacfarlane.net/babelmark2/?text=%60Foo%0A----%0A%60%0A%0A%3Ca+title%3D%22a+lot%0A---%0Aof+dashes%22%2F%3E%0A
  #    html = "<h2>`Foo</h2>\n<p>`</p>\n<h2>&lt;a title=&quot;a lot</h2>\n<p>of dashes&quot;/&gt;</p>\n"
  #    markdown = "`Foo\n----\n`\n\n<a title=\"a lot\n---\nof dashes\"/>\n"
  #
  describe "Setext headers with some context" do 

    test "h1 after an unordered list" do 
      markdown = "* foo\n\nbar\n==="
      html     = gen([{:ul, {:li, "foo"}}, {:h1, "bar"}])
      messages = []
      
      assert as_html(markdown) == {:ok, html, messages}
    end

  end

end

# SPDX-License-Identifier: Apache-2.0
