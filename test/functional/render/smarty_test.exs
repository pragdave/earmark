defmodule SmartyTest do
  use ExUnit.Case

  import Support.Helpers
  ############################################################
  # Quotes                                                    #
  ############################################################

  test "paired single" do
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
end
