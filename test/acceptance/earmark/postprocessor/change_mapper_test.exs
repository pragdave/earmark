defmodule Test.Acceptance.Earmark.Postprocessor.ChangeMapperTest do
  use ExUnit.Case

  describe "use case from Elixir Forum" do
    @markdown """
    Invariable
    ```
    WILL Be Lower
    ```
    {:.lower}
    Beta
    ```
    uppercase
    ```
    {:.upper}
    gAMMA
    """
    test "change case depending on class" do
      expected = "<p>\nInvariable</p>\n<pre class=\"lower\"><code>will be lower</code></pre>\n<p>\nBeta</p>\n<pre class=\"upper\"><code>UPPERCASE</code></pre>\n<p>\ngAMMA</p>\n"
      assert parse(@markdown) == expected
    end
  end

  defp parse(markdown) do
    options = [
      registered_processors: [&main_mapper/1]
    ]

    {:ok, html, _} = Earmark.as_html(markdown, options)
    html
  end

  defp main_mapper({_, atts, _, _} = node) do
    classes = Earmark.AstTools.find_att_in_node(node, "class") || ""

    cond do
      classes =~ "lower" -> {&lower_mapper/1, node}
      classes =~ "upper" -> {&upper_mapper/1, node}
      true -> node
    end
  end
  defp main_mapper(text), do: text

  defp lower_mapper(node) when is_tuple(node), do: node
  defp lower_mapper(text), do: String.downcase(text)

  defp upper_mapper(node) when is_tuple(node), do: node
  defp upper_mapper(text), do: String.upcase(text)
end

# SPDX-License-Identifier: Apache-2.0
