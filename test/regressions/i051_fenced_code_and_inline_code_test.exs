defmodule Regressions.I051FencedCodeAndInlineCodeTest do
  use ExUnit.Case

  @i51_not_a_fenced_block """
  ```elixir ```
  """
  test "https://github.com/pragdave/earmark/issues/51" do
    result = Earmark.as_html! @i51_not_a_fenced_block
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

  test"Escape html in text different than in url" do
    result = Earmark.as_html! @url_to_validate
    assert result == """
    <p><a href="http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#%3C%3C%3E%3E/1">&lt;&lt;&gt;&gt;/1</a></p>
    """

    result = Earmark.as_html! @code_block_to_validate
    assert result == """
    <pre><code class="elixir">term &lt; term :: boolean</code></pre>
    """

    result = Earmark.as_html! "[&expr/1](http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#&expr/1)"
    assert result == """
    <p><a href="http://elixir-lang.org/docs/master/elixir/Kernel.SpecialForms.htm#&amp;expr/1">&amp;expr/1</a></p>
    """
  end

end
