defmodule Regressions.I089LinkInsideBracketsTest do
  use ExUnit.Case

  test "non regression" do
    str = "before [text](link) after"
    assert ~s{<p>before <a href="link">text</a> after</p>\n} == Earmark.as_html!(str)
  end
  test "link inside barackets" do
    str = "[[text](link)]"
    assert ~s{<p>[<a href="link">text</a>]</p>\n} == Earmark.as_html!(str)
  end
  test "link with title inside brackets" do
    str = "[[text](link 'title')]"
    assert ~s{<p>[<a href="link" title="title">text</a>]</p>\n} == Earmark.as_html!(str)
  end
  test "ambigous link" do
    str = "[[text](inner)](outer)"
    assert ~s{<p><a href="outer">[text](inner)</a></p>\n} == Earmark.as_html!(str)
  end
end

# SPDX-License-Identifier: Apache-2.0
