defmodule Regressions.I096CodeClassParametrizationTest do
  use ExUnit.Case

  defp html(str, code_class_prefix \\ nil) do
    Earmark.as_html!( str, %Earmark.Options{code_class_prefix: code_class_prefix} )
  end

  test "as you were" do
    expected = ~s(<pre><code class="elixir">def the_answer</code></pre>\n)
    assert html("```elixir\ndef the_answer") == expected
  end

  test "add a prefix" do
    expected = ~s(<pre><code class="elixir lang-elixir">def the_answer</code></pre>\n)
    assert html("```elixir\ndef the_answer", "lang-") == expected
  end

  test "or many" do
    expected = ~s(<pre><code class="elixir lang-elixir syntaxelixir">def the_answer</code></pre>\n)
    assert html("```elixir\ndef the_answer", "lang- syntax") == expected
  end

  test "don't fence me in, turn me lose..." do
    expected = ~s(<pre><code class="elixir lang-elixir syntaxelixir">def the_answer</code></pre>\n)
    assert html("~~~elixir\ndef the_answer", "lang- syntax") == expected

  end
end
