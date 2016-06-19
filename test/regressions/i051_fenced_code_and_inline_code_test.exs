defmodule Regressions.I051FencedCodeAndInlineCodeTest do
  use ExUnit.Case
  import Test.Support.SilenceIo, only: [with_silent_io: 2]

  @i51_not_a_fenced_block """
  ```elixir ```
  """
  test "https://github.com/pragdave/earmark/issues/51" do
    result = with_silent_io(:stderr, fn ->
      Earmark.to_html @i51_not_a_fenced_block
    end)
    assert result == ~s[<p><code class=\"inline\">elixir</code></p>\n]
  end


  @url_to_validate """
  [<<>>/1](http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#<<>>/1)
  """

  @code_block_to_validate """
  ```elixir
  term < term :: boolean
  ```
  """

  @code_inline_to_validate """
  `term < term :: boolean`
  """

  test"Escape html in text different than in url" do
    result = Earmark.to_html @url_to_validate
    assert result == """
    <p><a href="http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#%3C%3C%3E%3E/1">&lt;&lt;&gt;&gt;/1</a></p>
    """

    result = Earmark.to_html @code_block_to_validate
    assert result == """
    <pre><code class="elixir">term &lt; term :: boolean</code></pre>
    """

    result = Earmark.to_html "[&expr/1](http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#&expr/1)"
    assert result == """
    <p><a href="http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#&amp;expr/1">&amp;expr/1</a></p>
    """
  end

end
