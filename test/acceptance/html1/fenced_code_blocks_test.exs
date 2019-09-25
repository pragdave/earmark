defmodule Acceptance.Html1.FencedCodeBlocksTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Fenced code blocks" do
    test "no lang" do
      markdown = "```\n<\n >\n```\n"
      html     = fcode("&lt;\n &gt;", "") 
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "still no lang" do
      markdown = "~~~\n<\n >\n~~~\n"
      html     = fcode("&lt;\n &gt;", "") 
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "elixir 's the name" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = fcode("aaa\n~~~", "elixir")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "with a code_class_prefix" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = fcode("aaa\n~~~", "elixir lang-elixir")
      messages = []

      assert to_html1(markdown, code_class_prefix: "lang-") == {:ok, html, messages}
    end

    test "look mam, more lines" do
      markdown = "   ```\naaa\nb\n  ```\n"
      html     = fcode("aaa\nb", "")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end

  describe "do not make too many assumptions about programming language names" do
    test "at least the existing ones shall work" do
      markdown = "```c#\nI do not know c# code\n```\n"
      html     = fcode("I do not know c# code", "c#")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "and let us anticipate creative language designers too" do
      markdown = "```42lang!\nassert x == 42\n```\n"
      html     = fcode("assert x == 42", "42lang!")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "be careful about what can go into an HTML attribute though" do
      markdown = "```a<b&\nassert x == 42\n```\n"
      html     = fcode("assert x == 42", "a&lt;b&amp;")
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
