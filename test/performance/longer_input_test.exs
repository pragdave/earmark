defmodule Performance.LongerInputTest do
  use Support.PerformanceTestCase

  describe "some test data" do
    test "medium" do
      ast = convert_file("medium.md", 100, :ast)
      assert Enum.count(ast) == 8300
    end
  end
  
end
