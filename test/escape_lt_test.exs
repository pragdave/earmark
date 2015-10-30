defmodule EscapeLtTest do
  use ExUnit.Case

  defp para content do
    "<p>#{content}</p>\n"
  end

  ##############
  # Plain Text #
  ##############

  @tag :xxx
  test "< is escaped" do
    result = Earmark.to_html "<"
    assert result == para( "&lt;" )
  end

  test "< is escaped as a prefix" do
    result = Earmark.to_html "<hello"
    assert result == para("&lt;hello")
  end

  test "< is escaped as an infix" do
    result = Earmark.to_html "he<llo"
    assert result == para( "he&lt;llo" )
  end

  test "< is esacped as a suffix" do
    result = Earmark.to_html "hello<"
    assert result == para( "hello&lt;" )
  end
  ############
  # Emphasis #
  ############
  test "< is escaped inside _ ... _ " do
    result = Earmark.to_html( "_<hello_" )
    assert result == para( "<em>&lt;hello</em>" )
  end
  
  ###############
  # Inline HTML #
  ###############

  test "inline HTML starting with <" do
    result = Earmark.to_html(~s[<a <span class="red">a&b</span> color])
    assert result == para( ~s[&lt;a <span class="red">a&amp;b</span> color] )
  end

  test "inline HTML < before first tag" do
    result = Earmark.to_html(~s[start<a <span class="red">a&b</span> color])
    assert result == para( ~s[start&lt;a <span class="red">a&amp;b</span> color] )
  end

  test "inline HTML < inside tag" do
    result = Earmark.to_html(~s[a <span class="red">a&b<c</span> color])
    assert result == para( ~s[a <span class="red">a&amp;b&lt;c</span> color] )
  end

  test "inline HTML < after tag" do
    result = Earmark.to_html(~s[<span class="red">a&b</span> <color])
    assert result == para( ~s[<span class="red">a&amp;b</span> &lt;color] )
  end
end
