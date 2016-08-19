defmodule CodeTest do
  use ExUnit.Case

  import Support.Helpers

  ##########
  # Inline #
  ##########

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
  test "" do
    result = convert_pedantic("a 'single' quote")
    assert result == "a ‘single’ quote"
  end

  test "apostrophe" do
    result = convert_pedantic("a single's quote")
    assert result == "a single’s quote"
  end

  test "paired single before puncuation" do
    Enum.each '.]})?!', fn (punct) ->
      result = convert_pedantic("a 'single'" <> <<punct>>)
      assert result == "a ‘single’"  <> <<punct>>
    end
  end

  test "paired double" do
    result = convert_pedantic("a \"double\" quote")
    assert result == "a “double” quote"
  end

  test "paired double before puncuation" do
    Enum.each '.]})?!', fn (punct) ->
      result = convert_pedantic("a \"double\"" <> <<punct>>)
      assert result == "a “double”"  <> <<punct>>
    end
  end

  test "closing quotes after tag" do
    result = convert_pedantic ~s(a "**test**")
    assert result == "a “<strong>test</strong>”"
  end

  test "closing single quotes after tag" do
    result = convert_pedantic ~s(a '**test**')
    assert result == "a ‘<strong>test</strong>’"
  end

  test "another closing single quotes after tag" do
    result = convert_pedantic "for `key` in `app`'s environment"
    assert result == ~s(for <code class="inline">key</code> in <code class="inline">app</code>’s environment)
  end

  ##########
  # Blocks #
  ##########

  test "simple code block" do
    result = Earmark.to_html "```\ndefmodule\n```"
    assert result == ~s(<pre><code class="">defmodule</code></pre>\n)
  end
  test "indented code block" do
    result = Earmark.to_html "    defmodule\n    end"
    assert result == ~s(<pre><code>defmodule\nend</code></pre>\n)
  end
  test "indented code block (increasing indent)" do
    result = Earmark.to_html "    defmodule\n      defstruct"
    assert result == ~s(<pre><code>defmodule\n  defstruct</code></pre>\n)
  end
  test "indented code block (decreasing indent)" do
    result = Earmark.to_html "      # Hello\n    end"
    assert result == ~s(<pre><code>  # Hello\nend</code></pre>\n)
  end
  test "code block (decreasing indent)" do
    result = Earmark.to_html "```elixir\n  # Hello\nend\n```"
    assert result == ~s(<pre><code class="elixir">  # Hello\nend</code></pre>\n)
  end
end
