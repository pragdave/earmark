defmodule Regressions.I050ListsWithCodeTest do
  use ExUnit.Case
  import Test.Support.SilenceIo, only: [with_silent_io: 2]
  @i50_inline_code_in_list_item """
  + ```escape```
  """
  test "https://github.com/pragdave/earmark/issues/50" do
    result = with_silent_io(:stderr, fn ->
      Earmark.to_html @i50_inline_code_in_list_item
    end)
    assert result == ~s[<ul>\n<li><code class="inline">escape</code>\n</li>\n</ul>\n]
  end

end
