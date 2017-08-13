defmodule Regressions.I154EscapeSingleBackslashInInlineCodeTest do
  use ExUnit.Case

  test "`\\\\`" do
    markdown = "`\\\\`"
    # To avoid any confusion about what markdown really is
    assert 4 == String.length( markdown )
    assert {:ok, "<p><code class=\"inline\">\\\\</code></p>\n", []} == Earmark.as_html(markdown)
  end

  test "`\\`" do
    markdown = "`\\`"
    # To avoid any confusion about what markdown really is
    assert 3 == String.length( markdown )
    assert {:error, "<p><code class=\"inline\">\\</code></p>\n", [{:warning, 1, "Closing unclosed backquotes ` at end of input"}]} ==
      Earmark.as_html(markdown)
  end

end
