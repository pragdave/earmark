defmodule SanitizeTest do
  use ExUnit.Case

  # TODO: Figure out a test case where sanitize makes a difference
  test "sanitize option is legal" do
    Earmark.as_html!("Sanitized", %Earmark.Options{sanitize: true})
  end

end

# SPDX-License-Identifier: Apache-2.0
