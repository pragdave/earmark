defmodule Acceptance.Ast.CommentTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_ast: 1]

  describe "HTML Comments" do
    test "one line" do
      markdown = "<!-- Hello -->"
      ast      = {:comment, [], [" Hello "], %{comment: true}}
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "more lines" do
      markdown = "<!-- Hello\n World-->"
      ast      = {:comment, [], [" Hello", " World"], %{comment: true}}
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "what about the closing" do
      markdown = "<!-- Hello\n World -->garbish"
      ast      = {:comment, [], [" Hello", " World "], %{comment: true}}
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end
# SPDX-License-Identifier: Apache-2.0

