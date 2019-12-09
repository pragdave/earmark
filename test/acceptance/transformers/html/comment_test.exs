defmodule Acceptance.Transformers.Html.CommentTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "HTML Comments" do
    test "one line" do
      markdown = "<!-- Hello -->"
      html     = "<!-- Hello -->"

      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "more lines" do
      markdown = "<!-- Hello\n World -->"
      html     = "<!-- Hello\n     World -->"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "what about the closing" do
      # TODO: Open an issue, I guess there will be esoteric cases
      # where this will break :O
      markdown = "<!-- Hello\n World -->garbish"
      html     = "<!-- Hello\n     World -->"
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
