defmodule Acceptance.Ast.EmphasisTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1, as_ast: 2]

  describe "Emphasis" do
    @tag :ast
    test "important" do
      markdown = "*foo bar*\n"
      html     = "<p><em>foo bar</em></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "imporatant quotes" do
      markdown = "a*\"foo\"*\n"
      html     = "<p>a<em>&quot;foo&quot;</em></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown, smartypants: false) == {:ok, [ast], messages}
    end

    @tag :ast
    test "important _" do
      markdown = "_foo bar_\n"
      html     = "<p><em>foo bar</em></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "dont get confused" do
      markdown = "_foo*\n"
      html     = "<p>_foo*</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "that should make you smile" do
      markdown = "_foo_bar_baz_\n"
      html     = "<p><em>foo_bar_baz</em></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "stronger" do
      markdown = "**foo bar**\n"
      html     = "<p><strong>foo bar</strong></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "stronger insisde" do
      markdown = "foo**bar**\n"
      html     = "<p>foo<strong>bar</strong></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "stronger together" do
      markdown = "__foo bar__\n"
      html     = "<p><strong>foo bar</strong></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "let no evil underscores divide us" do
      markdown = "**foo__bar**\n"
      html     = "<p><strong>foo__bar</strong></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "strong **and** stronger" do
      markdown = "*(**foo**)*\n"
      html     = "<p><em>(<strong>foo</strong>)</em></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "stronger **and** strong" do
      markdown = "**(*foo*)**\n"
      html     = "<p><strong>(<em>foo</em>)</strong></p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    @tag :ast
    test "one is not strong enough" do
      markdown = "foo*\n"
      html     = "<p>foo*</p>\n"
      ast      = Floki.parse(html) |> IO.inspect
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
