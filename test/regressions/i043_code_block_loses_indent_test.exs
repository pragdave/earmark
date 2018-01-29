defmodule Regressions.I043CodeBlockLosesIndentTest do
  use ExUnit.Case

  @indented_code_block """
                  alpha
              beta
          """
  test "https://github.com/pragdave/earmark/issues/43" do
    result = Earmark.as_html! @indented_code_block
    assert result == ~s[<pre><code>    alpha\nbeta</code></pre>\n]
  end
end

# SPDX-License-Identifier: Apache-2.0
