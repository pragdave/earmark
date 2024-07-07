defmodule EarmarkTest do
  use ExUnit.Case

  doctest Earmark, import: true

  describe "some basic functions" do
    test "version" do
      assert Regex.match?(~r{\A\d+\.\d+}, to_string(Earmark.version()))
    end
  end

  describe "from_file!" do
    test "recursive" do
      result = Earmark.from_file!("test/fixtures/include/recursive.md.eex")

      assert result == "<h1>\nMain</h1>\n<h2>\nLevel2</h2>\n"
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
