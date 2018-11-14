defmodule Regressions.I048MultilineQuotedTextTest do
  use ExUnit.Case

  @i48_multiline_inline_code """
  `a
  * b`
  """
  test "https://github.com/pragdave/earmark/issues/48 (1)" do
    result = Earmark.as_html!(@i48_multiline_inline_code)
    assert result == ~s[<p><code class="inline">a * b</code></p>\n]
  end

  @i48_multiline_code_in_list """
  * `a
  * b`
  """
  test "https://github.com/pragdave/earmark/issues/48 (2)" do
    result = Earmark.as_html!(@i48_multiline_code_in_list)
    assert result == ~s[<ul>\n<li><code class="inline">a * b</code>\n</li>\n</ul>\n]
  end
end

# SPDX-License-Identifier: Apache-2.0
