defmodule Test.Lib.Task.Earmark.ImplementationTest do
  use ExUnit.Case

  import Mix.Tasks.Earmark

  describe "simple fixture" do
    test "no switches" do
      run(~W[test/fixtures/base.html.eex])
      expected = []
      result = File.read!("test/fixtures/base.html") |> Floki.parse_fragment!


      assert result == expected

    end
  end
end
