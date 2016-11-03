defmodule EscapeLtTest do
  use ExUnit.Case

  import Support.Helpers

  ##############
  # Plain Text #
  ##############

  test "< is escaped" do
    result = convert_pedantic "<"
    assert result ==  "&lt;"
  end

  test "< is escaped as a prefix" do
    result = convert_pedantic "<hello"
    assert result == "&lt;hello"
  end

  test "< is escaped as an infix" do
    result = convert_pedantic "he<llo"
    assert result ==  "he&lt;llo"
  end

  test "< is esacped as a suffix" do
    result = convert_pedantic "hello<"
    assert result ==  "hello&lt;"
  end
  ############
  # Emphasis #
  ############
  test "< is escaped inside _ ... _ " do
    result = convert_pedantic( "_<hello_" )
    assert result ==  "<em>&lt;hello</em>"
  end

  ###############
  # Inline HTML #
  ###############

  test "inline HTML starting with <" do
    result = convert_pedantic(~s[<a <span class="red">a&b</span> color])
    assert result ==  ~s[&lt;a <span class="red">a&amp;b</span> color]
  end

  test "inline HTML < before first tag" do
    result = convert_pedantic(~s[start<a <span class="red">a&b</span> color])
    assert result ==  ~s[start&lt;a <span class="red">a&amp;b</span> color]
  end

  test "inline HTML < inside tag" do
    result = convert_pedantic(~s[a <span class="red">a&b<c</span> color])
    assert result ==  ~s[a <span class="red">a&amp;b&lt;c</span> color]
  end

  test "inline HTML < after tag" do
    result = convert_pedantic(~s[<span class="red">a&b</span> <color])
    assert result ==  ~s[<span class="red">a&amp;b</span> &lt;color]
  end
end
