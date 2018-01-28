defmodule Regressions.I085IndentedFencedCodeTest do
  use ExUnit.Case

  @moduletag :wip
  # Not in list --> verbatim
  test "code block (fenced with uniform 4-space indents)" do
    result = Earmark.as_html! "    ```elixir\n    defmodule\n    ```"
    assert result == "<pre><code>```elixir\ndefmodule\n```</code></pre>\n"
  end

  test "code block (fenced with non-uniform 2- and 4-space indents)" do
    result = Earmark.as_html! "  ```elixir\n    defmodule\n    ```"
    assert result == "<pre><code class=\"elixir\">    defmodule\n    ```</code></pre>\n"
  end

  test "inline code" do
    result = Earmark.as_html! "1. one\n   Hello ```erlang World\n Universe ```"
    assert result == "<ol>\n<li>one\n   Hello <code class=\"inline\">erlang World\n Universe</code>\n</li>\n</ol>\n"
  end

  # In list items, interpret the backtick fence
  test "code block (in list item, with 4-space indent and ending fence in-line)" do
    result = Earmark.as_html! "1. one\n\n    ```elixir\n    defmodule```\n"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule```</code></pre>\n</li>\n</ol>\n"
  end

  test "backtick code fence in list item, closing fence idemaligned" do
    result = Earmark.as_html! "1. one\n\n    ```elixir\n      defmodule\n    ```"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">  defmodule</code></pre>\n</li>\n</ol>\n"

  end
  test "backtick code fence in list item, closing fence less aligned" do
    result = Earmark.as_html! "1. one\n\n    ```elixir\n    defmodule\n  ```"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">defmodule</code></pre>\n</li>\n</ol>\n"
  end

  test "backtick code fence in list item, closing fence more aligned" do
    result = Earmark.as_html! "1. one\n    ```elixir\n    defmodule\n       ```"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">defmodule</code></pre>\n</li>\n</ol>\n"
  end

  test "tilde code fence in list item, closing fence idemaligned" do
    result = Earmark.as_html! "1. one\n\n    ~~~elixir\n    defmodule\n    ~~~"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">defmodule</code></pre>\n</li>\n</ol>\n"
  end

  test "tilde code fence in list item, closing fence idemaligned, no lang" do
    result = Earmark.as_html! "1. one\n\n    ~~~\n    defmodule\n    ~~~"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"\">defmodule</code></pre>\n</li>\n</ol>\n"
  end
  test "tilde code fence in list item, closing fence less aligned" do
    result = Earmark.as_html! "1. one\n\n    ~~~elixir\n    defmodule\n  ~~~"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule</code></pre>\n</li>\n</ol>\n"
  end

  test "tilde code fence in list item, closing fence more aligned" do
    result = Earmark.as_html! "  1. one\n    ~~~elixir\n    defmodule\n        ~~~"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule</code></pre>\n</li>\n</ol>\n"
  end
end

# SPDX-License-Identifier: Apache-2.0
