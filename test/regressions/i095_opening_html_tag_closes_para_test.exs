defmodule Regressions.I095OpeningHtmlTagClosesParaTest do
  use ExUnit.Case, async: true

  @moduledoc """
  Addressed in issue [#326](https://github.com/pragdave/earmark/issues/326)
  """

  @moduletag :wip

  test "html inline tag as a complete line" do
    expected = "<p>foo\n<b>bar</b></p>\n"
    assert Earmark.as_html!("foo\n<b>bar</b>") == expected
  end
  test "html inline tag at beginning of line" do
    expected = "<p>foo\n<b>bar</b> baz</p>\n"
    assert Earmark.as_html!("foo\n<b>bar</b> baz") == expected
  end
  test "html inline tag in middle of line" do
    expected = "<p>foo\n <b>bar</b> baz</p>\n"
    assert Earmark.as_html!("foo\n <b>bar</b> baz") == expected
  end
  test "html inline tag at end of line" do
    expected = "<p>foo\nbaz <b>bar</b></p>\n"
    assert Earmark.as_html!("foo\nbaz <b>bar</b>") == expected
  end

  test "html block tag at beginning of line" do
    expected = "<p>foo</p>\n<h5>bar</h5> baz"
    assert Earmark.as_html!("foo\n<h5>bar</h5> baz") == expected
  end

  # Transforms it to an inline, which is probably not what was wanted
  # but it is explained in the README
  test "html block tag in middle of line" do
    expected = "<p>foo\n <h5>bar</h5> baz</p>\n"
    assert Earmark.as_html!("foo\n <h5>bar</h5> baz") == expected
  end
  # Transforms it to an inline, which is probably not what was wanted
  # but it is explained in the README
  test "html block tag at end of line" do
    expected = "<p>foo\nbaz <h5>bar</h5></p>\n"
    assert Earmark.as_html!("foo\nbaz <h5>bar</h5>") == expected
  end
end

# SPDX-License-Identifier: Apache-2.0
