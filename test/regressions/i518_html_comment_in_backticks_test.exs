defmodule Test.Regressions.I518HtmlCommentInBackticksTest do
  use ExUnit.Case

  test "HTML comment inside backticks is rendered as inline code" do
    md = "some source `<!-- 2 -->`"
    html = "<p>\nsome source <code class=\"inline\">&lt;!-- 2 --&gt;</code></p>\n"
    assert Earmark.as_html(md) == {:ok, html, []}
  end

  test "HTML comment mid-line is rendered as a comment" do
    md = "text <!-- comment --> more text"
    html = "<p>\ntext <!-- comment -->\n more text</p>\n"
    assert Earmark.as_html(md) == {:ok, html, []}
  end
end
# SPDX-License-Identifier: Apache-2.0
