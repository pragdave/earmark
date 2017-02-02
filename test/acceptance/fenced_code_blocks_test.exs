defmodule Acceptance.FencedCodeBlocksTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_html: 1, as_html: 2]

  # describe "Fenced code blocks" do
    test "no lang" do
      markdown = "```\n<\n >\n```\n"
      html     = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "still no lang" do
      markdown = "~~~\n<\n >\n~~~\n"
      html     = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "elixir 's the name" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = "<pre><code class=\"elixir\">aaa\n~~~</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "with a code_class_prefix" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = "<pre><code class=\"elixir lang-elixir\">aaa\n~~~</code></pre>\n"
      messages = []

      assert as_html(markdown, code_class_prefix: "lang-") == {:ok, html, messages}
    end

    test "look mam, more lines" do
      markdown = "   ```\naaa\nb\n  ```\n"
      html     = "<pre><code class=\"\">aaa\nb</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

  # end
end
