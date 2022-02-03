defmodule Acceptance.Html.DiverseTest do
  use Support.AcceptanceTestCase

  import ExUnit.CaptureIO

  describe "etc" do
    test "entiy" do
      markdown = "`f&ouml;&ouml;`\n"
      html     = "<p>\n<code class=\"inline\">f&amp;ouml;&amp;ouml;</code></p>\n"

      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "spaec preserving" do
      markdown = "Multiple     spaces"
      html     = "<p>\nMultiple     spaces</p>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "syntax errors" do
      markdown = "A\nB\n="
      html     = "<p>\nA\nB</p>\n<p>\n</p>\n"
      messages = [{:warning, 3, "Unexpected line =" }]

      assert as_html(markdown) == {:error, html, messages}
    end

    test "syntax errors and standard error" do
      markdown = "A\nB\n="
      html     = "<p>\nA\nB</p>\n<p>\n</p>\n"

      error_message =
        capture_io(:stderr, fn ->
          assert Earmark.as_html!(markdown) == html
        end) |> Support.Helpers.remove_deprecation_messages

      assert error_message == "<no file>:3: warning: Unexpected line =\n"
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
