defmodule Regressions.I198EscapesInsideLinksTest do
  use ExUnit.Case, async: true


  describe "Links with escapes" do

    test "escaped backticks" do 
      markdown = "[hello \\`code\\`](http://some.where)"
      html     = ~s{<p><a href="http://some.where">hello `code`</a></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "escaped stars" do
      markdown = "[hello \\*world\\*](http://some.where)"
      html     = ~s{<p><a href="http://some.where">hello *world*</a></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "although brackets do not need escapes, we still have to render them correctly" do
      markdown = "[hello \\[world\\]](http://some.where)"
      html     = ~s{<p><a href="http://some.where">hello [world]</a></p>\n}
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end


  defp as_html(src), do: src |> Earmark.as_html(%Earmark.Options{timeout: 3_600_000})
end
