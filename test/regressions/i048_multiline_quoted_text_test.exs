defmodule Regressions.I048MultilineQuotedTextTest do
  use ExUnit.Case

  import Test.Support.SilenceIo, only: [with_silent_io: 2]

  @i48_multiline_inline_code """
  `a
  * b`
  """
  test "https://github.com/pragdave/earmark/issues/48 (1)" do
    result = with_silent_io(:stderr, fn -> 
      Earmark.to_html @i48_multiline_inline_code
    end)
    assert result == ~s[<p><code class="inline">a\n* b</code></p>\n]
  end

  @i48_multiline_code_in_list """
  * `a
  * b`
  """
  test "https://github.com/pragdave/earmark/issues/48 (2)" do
    result = with_silent_io(:stderr, fn -> 
      Earmark.to_html @i48_multiline_code_in_list
    end)
    assert result == ~s[<ul>\n<li><code class="inline">a\n* b</code>\n</li>\n</ul>\n]
  end
end
