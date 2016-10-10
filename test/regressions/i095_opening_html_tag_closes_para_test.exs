defmodule Regressions.I095OpeningHtmlTagClosesParaTest do
  use ExUnit.Case

  @moduletag :wip
  test "html tag at beginning of line" do
    expected = "<p>foo\n<b>bar</b> baz</p>\n"
    assert expected == Earmark.to_html("foo\n<b>bar</b> baz")
  end
  test "html tag in middle of line" do
    expected = "<p>foo\n <b>bar</b> baz</p>\n"
    assert expected == Earmark.to_html("foo\n <b>bar</b> baz")
  end
  test "html tag at end of line" do
    expected = "<p>foo\nbaz <b>bar</b></p>\n"
    assert expected == Earmark.to_html("foo\nbaz <b>bar</b>")
  end
end
