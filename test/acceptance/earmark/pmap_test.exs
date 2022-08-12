defmodule Test.Acceptance.Earmark.PmapTest do
  use ExUnit.Case

  describe "pmap" do
    test "it respects the order" do
      result = ~W[AlPha BETA gamma] |> Earmark.pmap(&String.downcase/1)
      assert result == ~W[alpha beta gamma]
    end

    test "with timeout" do
      assert_raise Earmark.Error, fn ->
        Earmark.pmap([1], fn _ -> Process.sleep(20) end, 10)
      end
    end
  end

end
# SPDX-License-Identifier: Apache-2.0
