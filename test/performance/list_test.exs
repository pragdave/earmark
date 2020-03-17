defmodule Performance.ListTest do
  use Support.PerformanceTestCase
  
  # describe "example" do
  #   test "checking" do
  #     IO.puts(make_list([{"1.", 2}, {"*", 3}, {"23.", 2}, {"-", 1}]))
  #   end
  # end

  describe "a huge list" do
    test "9_000 lines" do
      input = make_list([
        {"1.", 30}, {"-", 5}, {"23.", 10}, {"*", 6}
      ])
      Earmark.as_html!(input)
    end
    # Working since #249 which made list processing O(Prod(elements by level)) instead of exponential
    test "99_000 lines" do
      input = make_list([
        {"1.", 30}, {"-", 5}, {"23.", 10}, {"*", 6}, {"-", 11}
      ])
      Earmark.as_html!(input)
    end
  end


end
