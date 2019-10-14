defmodule EarmarkTest do
  use ExUnit.Case

  doctest Earmark

  describe "some basic functions" do
    test "version" do
      assert Regex.match?(~r{\A\d+\.\d+}, to_string(Earmark.version))
    end
  end
end
