defmodule Regressions.I050ListsWithCodeTest do
  use ExUnit.Case, async: true
  @i50_inline_code_in_list_item """
  + ```escape```
  """
  test "https://github.com/pragdave/earmark/issues/50" do
    result = Earmark.as_html! @i50_inline_code_in_list_item
    assert result == ~s[<ul>\n<li><code class="inline">escape</code>\n</li>\n</ul>\n]
  end

end

# SPDX-License-Identifier: Apache-2.0
