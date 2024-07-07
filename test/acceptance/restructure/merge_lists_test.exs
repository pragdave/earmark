defmodule Test.Acceptance.Restructure.MergeListsTest do
  use ExUnit.Case

  import Earmark.Restructure, only: [merge_lists: 2]

  message =
    "merge_lists takes two lists where the first list is not shorter and at most 1 longer than the second list"

  describe "merge lists' api is particular issue meaningful error messages" do
    test "if first list is too short" do
      assert_raise ArgumentError, unquote(message), fn ->
        merge_lists(~W[a b], [1, 2, 3])
      end
    end

    test "if first list is too long" do
      assert_raise ArgumentError, unquote(message), fn ->
        merge_lists(~W[a b], [])
      end
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
