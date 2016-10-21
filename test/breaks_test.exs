defmodule BreaksTest do
  use ExUnit.Case

  defp convert(markdown), do: markdown |> Earmark.to_html(%Earmark.Options{breaks: true})

  test "acceptance test 480 with breaks" do
    expected = "<blockquote><h1>Foo</h1>\n<p>bar<br/>baz</p>\n</blockquote>\n"
    markdown = "> # Foo\n> bar\n> baz\n"
    assert convert(markdown) == expected
  end

  test "acceptance test 490 with breaks" do
    expected = "<blockquote><p>bar<br/>baz<br/>foo</p>\n</blockquote>\n"
    markdown = "> bar\nbaz\n> foo\n"
    assert convert(markdown) == expected
  end

  test "acceptance test 580 with breaks" do
    expected = "<ol>\n<li>foo<br/>bar\n</li>\n</ol>\n"
    markdown = "1. foo\nbar"
    assert convert(markdown) == expected
  end

  test "acceptance test 581 with breaks" do
    expected = "<ul>\n<li>a<br/>b<br/>c\n</li>\n</ul>\n"
    markdown = "* a\n    b\nc"
    assert convert(markdown) == expected
  end

  test "acceptance test 582 with breaks" do
    expected = "<ul>\n<li>x<br/>a<br/>| A | B |\n</li>\n</ul>\n"
    markdown = "* x\n    a\n| A | B |"
    assert convert(markdown) == expected
  end

  test "acceptance test 583 with breaks" do
    expected = "<ul>\n<li>x<br/> | A | B |\n</li>\n</ul>\n"
    markdown = "* x\n | A | B |"
    assert convert(markdown) == expected
  end

  test "acceptance test 630 with breaks" do
    expected = "<p>*not emphasized*<br/>[not a link](/foo)<br/>`not code`<br/>1. not a list<br/>* not a list<br/># not a header<br/>[foo]: /url “not a reference”</p>\n"
    markdown = "\\*not emphasized\\*\n\\[not a link](/foo)\n\\`not code\\`\n1\\. not a list\n\\* not a list\n\\# not a header\n\\[foo]: /url \"not a reference\"\n"
    assert convert(markdown) == expected
  end

end
