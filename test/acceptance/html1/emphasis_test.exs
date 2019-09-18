defmodule Acceptance.Html1.EmphasisTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Emphasis" do
    test "important" do
      markdown = "*foo bar*\n"
      html     = para([ :em, "foo bar" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "imporatant quotes" do
      markdown = "a*\"foo\"*\n"
      html     = para([
        "a",
        :em,
        "&quot;foo&quot;" ])
      messages = []

      assert to_html1(markdown, smartypants: false) == {:ok, html, messages}
    end

    test "important _" do
      markdown = "_foo bar_\n"
      html     = para([ :em, "foo bar" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "dont get confused (unless you want to)" do
      markdown = "_foo*\n"
      html     = para("_foo*")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "that should make you smile" do
      markdown = "_foo_bar_baz_\n"
      html     = para([ :em, "foo_bar_baz" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "stronger" do
      markdown = "**foo bar**\n"
      html     = para([
        :strong, "foo bar"
      ])
      messages = [] 

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "stronger insisde" do
      markdown = "foo**bar**\n"
      html     = para([ 
        "foo",
        :strong,
        "bar" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "stronger together" do
      markdown = "__foo bar__\n"
      html     = para([:strong, "foo bar"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "let no evil underscores divide us" do
      markdown = "**foo__bar**\n"
      html     = para([:strong, "foo__bar"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "strong **and** stronger" do
      markdown = "*(**foo**)*\n"
      html     = para([
        :em,
        "(",
        :strong,
        "foo",
        :POP,
        ")"])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "stronger **and** strong" do
      markdown = "**(*foo*)**\n"
      html     = para([
        :strong,
        "(",
        :em,
        "foo",
        :POP,
        ")" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "one is not strong enough" do
      markdown = "foo*\n"
      html     = para("foo*")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
