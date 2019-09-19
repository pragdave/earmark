defmodule Acceptance.Html1.FencedCodeBlocksTest do
  use ExUnit.Case, async: true

  import Support.Html1Helpers
  
  @moduletag :html1

  describe "Fenced code blocks" do
    test "no lang" do
      markdown = "```\n<\n >\n```\n"
      html     = construct([
        :pre,
        {:code, ~s{class=""}},
        "&lt;\n &gt;" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "still no lang" do
      markdown = "~~~\n<\n >\n~~~\n"
      html     = construct([
        :pre,
        {:code, ~s{class=""}},
        "&lt;\n &gt;" ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "elixir 's the name" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = construct([
        :pre,
        {:code, ~s{class="elixir"}},
        "aaa\n~~~" ])
      messages = []


      assert to_html1(markdown) == {:ok, html, messages}
    end

    test "with a code_class_prefix" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = construct([
        :pre,
        {:code, ~s{class="elixir lang-elixir"}},
        "aaa\n~~~" ])
      messages = []

      assert to_html1(markdown, code_class_prefix: "lang-") == {:ok, html, messages}
    end

    test "look mam, more lines" do
      markdown = "   ```\naaa\nb\n  ```\n"
      html     = construct([
        :pre,
        {:code, ~s{class=""}},
        "aaa\nb"
      ])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end

  end
end

# SPDX-License-Identifier: Apache-2.0
