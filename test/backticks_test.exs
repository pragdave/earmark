defmodule BackticksTest do
  use ExUnit.Case

  import Support.Helpers

  ########
  # Code #
  ########

  test "backticks mean code" do
    result = convert_pedantic("the `printf` function")
    assert result == ~s[the <code class="inline">printf</code> function]
  end

  test "literal backticks can be included within doubled backticks" do
    result = convert_pedantic("``the ` character``")
    assert result == ~s[<code class="inline">the ` character</code>]
  end

  test "a space after the opening and before the closing doubled backticks are ignored" do
    result = convert_pedantic("`` the ` character``")
    assert result == ~s[<code class="inline">the ` character</code>]
  end

  test "single backtick with spaces inside doubled backticks" do
    result = convert_pedantic("`` ` ``")
    assert result == ~s[<code class="inline">`</code>]
  end

  test "ampersands and angle brackets are escaped in code" do
    result = convert_pedantic("the `<a> &123;` function")
    expect = 
      ~s[the <code class="inline">&lt;a&gt; &amp;123;</code> function]    
    assert result == expect
  end
end
