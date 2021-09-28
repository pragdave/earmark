defmodule EarmarkTest do
  use ExUnit.Case

  doctest Earmark, import: true

  describe "some basic functions" do
    test "version" do
      assert Regex.match?(~r{\A\d+\.\d+}, to_string(Earmark.version))
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
