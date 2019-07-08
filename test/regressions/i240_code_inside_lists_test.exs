defmodule Regressions.I240CodeInsideListsTest do
  use ExUnit.Case
  import Support.Helpers, only: [as_html: 1]

  describe "code in a list" do
    @simple """
    - li

          Hello
    """
    test "in body" do
      html = "<ul>\n<li><p>li</p>\n<pre><code>Hello</code></pre>\n</li>\n</ul>\n"
      messages = []

      assert as_html(@simple) == {:ok, html, messages}
    end
  end
end
