defmodule Regressions.I021EscapeAmpInCodeBlocksTest do
  use ExUnit.Case
  @code_blocks_escape """
      escape("Hello <world>")
      "Hello &lt;world&gt;"
  """

  test "Issue https://github.com/pragdave/earmark/issues/21" do
    result = Earmark.to_html @code_blocks_escape
    assert result == """
                     <pre><code>escape(&quot;Hello &lt;world&gt;&quot;)
                     &quot;Hello &amp;lt;world&amp;gt;&quot;</code></pre>
                     """
  end

end
