defmodule ListAndTablesTest do
  use ExUnit.Case, async: true

  defp ul lines do
    """
    <ul>
    #{Enum.map( lines, &("<li>#{&1}\n</li>\n") )}</ul>
    """
  end

  test "Simple list render with |" do
    result = Earmark.as_html!(["* one | half", "* two | third"])
    expected = ul([ "one | half", "two | third" ])
    assert result == expected
  end

  test "Simple list render one implicit item with |" do
    result = Earmark.as_html!([ "- a", "b | c"])
    expected = ul(["a\nb | c"])
    assert result == expected
  end

  test "Simple list render two implicit items with |" do
    result = Earmark.as_html!( ["- a", "b | c", "d | e"] )
    expected = ul(["a\nb | c\nd | e"])
    assert result == expected
  end

  test "Alternating list and table lines" do
    result = Earmark.as_html!( ["- a", "b | c", "d", "e | f"] )
    expected = ul(["a\nb | c\nd\ne | f"])
    assert result == expected
  end

  test "Alternating table lines and text" do
    result = Earmark.as_html!( ["- a | b", "c", "d", "e | f"] )
    expected = ul(["a | b\nc\nd\ne | f"])
    assert result == expected
  end

  test "Alternating table and indented text lines" do
    result = Earmark.as_html!( ["- a", "  b", "e | f"] )
    expected = ul(["a\nb\ne | f"])
    assert result == expected
  end

  test "Alternating text and indented table lines" do
    result = Earmark.as_html!( ["- a", "   b | c", "e | f"] )
    expected = ul(["a\n b | c\ne | f"])
    assert result == expected
  end

  test "Same as above but at end of list" do
    result = Earmark.as_html!( ["- 0", "- a", "   b | c", "e | f"] )
    expected = ul(["0", "a\n b | c\ne | f"])
    assert result == expected
  end

  test "Same as above but in middle of list" do
    result = Earmark.as_html!( ["- 0", "- a", "   b | c", "e | f", "- Ω"] )
    expected = ul(["0", "a\n b | c\ne | f", "Ω"])
    assert result == expected
  end

  test "Still tables in lists" do
    result = Earmark.as_html!( ["- | a | b |", "| c | d |"] )
    expected = ul([ """
                    <table>
                    <tbody>
                    <tr>
                    <td style="text-align: left">a</td><td style="text-align: left">b</td>
                    </tr>
                    <tr>
                    <td style="text-align: left">c</td><td style="text-align: left">d</td>
                    </tr>
                    </tbody>
                    """ <> "</table>"
                    ])
    assert result == expected
  end
end

# SPDX-License-Identifier: Apache-2.0
