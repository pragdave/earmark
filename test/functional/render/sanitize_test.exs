defmodule SanitizeTest do
  use ExUnit.Case

  test "sanitize option is deprecated" do
    {:ok, "<p>Sanitized</p>\n", [{:deprecation, message, 0}]} = Earmark.as_html("Sanitized", %Earmark.Options{sanitize: true})
    assert message == "DEPRECATED: The sanitize option will be removed in Earmark 1.4"
  end

end

# SPDX-License-Identifier: Apache-2.0
