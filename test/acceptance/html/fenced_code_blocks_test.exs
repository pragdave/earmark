defmodule Acceptance.Html.FencedCodeBlocksTest do
  use Support.AcceptanceTestCase

  describe "Fenced code blocks" do
    test "no lang" do
      markdown = "```\n<\n >\n```\n"
      html     = "<pre><code>&lt;\n &gt;</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "still no lang" do
      markdown = "~~~\n<\n >\n~~~\n"
      html     = "<pre><code>&lt;\n &gt;</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "longer with shorter inside" do
      markdown = "~~~~\n<\n~~~\nsome code\n ~~~\n >\n~~~~\n"
      html     = "<pre><code>&lt;\n~~~\nsome code\n ~~~\n &gt;</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
    test "elixir 's the name" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      html     = "<pre><code class=\"elixir\">aaa\n~~~</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "elixir with longer fence" do
      markdown = "`````elixir\n````\n```\n````\n`````"
      html     = "<pre><code class=\"elixir\">````\n```\n````</code></pre>\n"
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
      html     = "<pre><code>aaa\nb</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end

  describe "do not make too many assumptions about programming language names" do
    test "at least the existing ones shall work" do
      markdown = "```c#\nI do not know c# code\n```\n"
      html     = "<pre><code class=\"c#\">I do not know c# code</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "and let us anticipate creative language designers too" do
      markdown = "```42lang!\nassert x == 42\n```\n"
      html     = "<pre><code class=\"42lang!\">assert x == 42</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end

    test "be careful about what can go into an HTML attribute though" do
      markdown = "```a<b&\nassert x == 42\n```\n"
      html     = "<pre><code class=\"a&lt;b&amp;\">assert x == 42</code></pre>\n"
      messages = []

      assert as_html(markdown) == {:ok, html, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
