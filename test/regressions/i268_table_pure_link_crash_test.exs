defmodule Regressions.I268TablePureKinkCrashTest do
  use ExUnit.Case

  describe "Deprecation messages for pure links inside tables" do

    test "simple case -> working" do
      {markdown, expected_html, expected_depr_lnbs} =  make_test_data([0, 1])

      {:ok, html, messages} = Earmark.as_html(markdown)
      assert html == expected_html
      assert extract_depr_lnbs(messages) == expected_depr_lnbs
    end

    test "too many deprecations" do
      {markdown, expected_html, expected_depr_lnbs} =  make_test_data([0, 1, 1])

      {:ok, html, messages} = Earmark.as_html(markdown)
      assert html == expected_html
      assert extract_depr_lnbs(messages) == expected_depr_lnbs
    end

    test "exponential?" do
      {markdown, expected_html, expected_depr_lnbs} =  make_test_data([0, 1, 1, 0, 0, 1])

      {:ok, html, messages} = Earmark.as_html(markdown)
      assert html == expected_html
      assert extract_depr_lnbs(messages) == expected_depr_lnbs
    end

    test "or not" do
      {markdown, expected_html, expected_depr_lnbs} =  make_test_data([0, 1, 1| Stream.cycle([0])|>Enum.take(1000)])

      {:ok, html, messages} = Earmark.as_html(markdown)
      assert html == expected_html
      assert extract_depr_lnbs(messages) == expected_depr_lnbs
    end
  end

  defp extract_depr_lnbs(messages) do
    messages
    |> Enum.map(fn {:deprecation, lnb, _} -> lnb end)
  end
  # E.g
  #    make_test_data([0, 1, 1]) -->
  #    { "| alpha | alpha |\n| alpha | http.... |\n",
  #      "<table><tr><td style=\"text-align: left;\">alpha</td>...",
  #      [{:deprecation, 2, "The string \"http...."}]
  defp make_test_data(lines) do
    {
      _make_markdown(lines),
      _make_html(lines),
      _make_deprecation_lnbs(lines)
    }
  end

  defp _make_cell(rowtype)
  defp _make_cell(0), do: "alpha"
  defp _make_cell(_), do: "http://example.com"

  defp _make_deprecation_lnbs(lines) do
    for {rowtype, lnb} <- lines
    |> Enum.zip(Stream.iterate(1, &(&1+1))),
      rowtype > 0, do: lnb
  end

  defp _make_html(lines) do
    "<table>\n" <>
      _make_html_rows(lines) <>
        "</table>\n"
  end
  @row_prefix "<tr>\n<td style=\"text-align: left\">alpha</td><td style=\"text-align: left\">"
  defp _make_html_rows(lines) do
    lines
    |> Enum.map(&("#{@row_prefix}#{_make_cell(&1)}</td>\n</tr>\n"))
    |> Enum.join
  end

  defp _make_markdown(lines) do
    lines
    |> Enum.map(&("| alpha | #{_make_cell(&1)} |\n"))
    |> Enum.join
  end
end
