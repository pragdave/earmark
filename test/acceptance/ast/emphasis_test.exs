defmodule Acceptance.Ast.EmphasisTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2]
  import EarmarkAstDsl

  describe "Emphasis" do
    test "important" do
      markdown = "*foo bar*\n"
      ast = p(em("foo bar"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "imporatant quotes" do
      markdown = "a*\"foo\"*\n"
      ast      = p(["a", em("\"foo\"")])
      messages = []

      assert as_ast(markdown, smartypants: false) == {:ok, [ast], messages}
    end

    test "important _" do
      markdown = "_foo bar_\n"
      ast      = p(em("foo bar"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "dont get confused" do
      markdown = "_foo*\n"
      ast      = p("_foo*")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "that should make you smile" do
      markdown = "_foo_bar_baz_\n"
      ast      = p(em("foo_bar_baz"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "stronger" do
      markdown = "**foo bar**\n"
      ast      = p(strong("foo bar"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "stronger insisde" do
      markdown = "foo**bar**\n"
      ast      = p(["foo", strong("bar")])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "stronger together" do
      markdown = "__foo bar__\n"
      ast      = p(strong("foo bar"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "let no evil underscores divide us" do
      markdown = "**foo__bar**\n"
      ast      = p(strong("foo__bar"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "strong **and** stronger" do
      markdown = "*(**foo**)*\n"
      ast      = p(em(["(", strong("foo"), ")"]))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "stronger **and** strong" do
      markdown = "**(*foo*)**\n"
      ast      = p(strong(["(", em("foo"), ")"]))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "one is not strong enough" do
      markdown = "foo*\n"
      ast      = p("foo*")
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    defp em(content), do: tag("em", content)
    defp strong(content), do: tag("strong", content)
  end
end

# SPDX-License-Identifier: Apache-2.0
