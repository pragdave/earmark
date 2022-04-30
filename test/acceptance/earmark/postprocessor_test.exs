defmodule Test.Acceptance.Earmark.PostprocessorTest do
  use ExUnit.Case

  describe "use case from Issue 446" do
    @no_code """
    just a line
    """
    test "no code" do
      assert parse(@no_code) == "<p>\njust a line</p>\n"
    end

    @inline_code """
    `alpha`
    ``beta
    ` ``
    """
    test "inline code" do
      expected = "<p>\n<code class=\"inline\">alpha</code>\n<code class=\"inline\">beta `</code></p>\n"
      assert parse(@inline_code) == expected
    end

    @code_to_be_replaced """
    pre
    ```
    immaterial
    ```
    post
    """
    test "replacing" do
      expected = "<p>\npre</p>\n<pre><code>xxx</code></pre>\n<p>\npost</p>\n"
      assert parse(@code_to_be_replaced) == expected
    end
  end

  defp parse(markdown) do
    options = [
      registered_processors: [
        {"code", &render_code_node/1}
      ]
    ]
    {:ok, post_html, _} = Earmark.as_html(markdown, options)
    post_html
  end

  defp render_code_node({"code", attrs, _content, meta} = node) do
    classes = Earmark.AstTools.find_att_in_node(node, "class") || ""
    cond do
      classes =~ "inline" -> node
      true -> {:replace, {"code", attrs, "xxx", meta}}
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
