defmodule Performance.LongerInputTest do
  use Support.PerformanceTestCase

  describe "some test data" do
    test "medium" do
      ast = convert_file("medium.md", :ast, 100)
      assert Enum.count(ast) == 8500
    end

    test "show data" do
      IO.puts convert_file("medium.md", :html)
    end
  end
end
