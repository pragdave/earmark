defmodule Acceptance.FencedCodeBlocksTest do
  use ExUnit.Case

  # describe "Fenced code blocks" do
    test "no lang" do
      markdown = "```\n<\n >\n```\n"
      # html     = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
      ast = {"pre", [], [{"code", [{"class", ""}], ["&lt;\n &gt;"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "still no lang" do
      markdown = "~~~\n<\n >\n~~~\n"
      # html     = "<pre><code class=\"\">&lt;\n &gt;</code></pre>\n"
      ast = {"pre", [], [{"code", [{"class", ""}], ["&lt;\n &gt;"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "elixir 's the name" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      # html     = "<pre><code class=\"elixir\">aaa\n~~~</code></pre>\n"
      ast = {"pre", [], [{"code", [{"class", "elixir"}], ["aaa~~~"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "with a code_class_prefix" do
      markdown = "```elixir\naaa\n~~~\n```\n"
      # html     = "<pre><code class=\"elixir lang-elixir\">aaa\n~~~</code></pre>\n"
      ast = {"pre", [], [{"code", [{"class", "elixir lang-elixir"}], ["aaa~~~"]}]}
      messages = []

      assert Earmark.Interface.html(markdown, code_class_prefix: "lang-") == {:ok, ast, messages}
    end

    test "look mam, more lines" do
      markdown = "   ```\naaa\nb\n  ```\n"
      # html     = "<pre><code class=\"\">aaa\nb</code></pre>\n"
      ast = {"pre", [], [{"code", [{"class", ""}], ["aaa\nb"]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

  # end
end
