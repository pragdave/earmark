defmodule Regressions.I085IndentedFencedCodeTest do
  use ExUnit.Case

  # Not in list --> verbatim
  test "code block (fenced with uniform 4-space indents)" do
    result = Earmark.to_html "    ```elixir\n    defmodule\n    ```"
    assert result == "<pre><code>```elixir\ndefmodule\n```</code></pre>\n"
  end

  test "code block (fenced with non-uniform 2- and 4-space indents)" do
    result = Earmark.to_html "  ```elixir\n    defmodule\n    ```"
    assert result == "<pre><code class=\"elixir\">    defmodule\n    ```</code></pre>\n"
  end

  # In list items, interpret the backtick fence
  test "code block (in list item, with 4-space indent and ending fence in-line)" do
    result = Earmark.to_html "1. one\n\n    ```elixir\n    defmodule```\n"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule```</code></pre>\n</li>\n</ol>\n"
  end

  test "backtick code fence in list item, closing fince idemaligned" do
    result = Earmark.to_html "1. one\n\n    ```elixir\n    defmodule\n    ```"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule</code></pre>\n</li>\n</ol>\n"

  end
  test "backtick code fence in list item, closing fince less aligned" do
    result = Earmark.to_html "1. one\n\n    ```elixir\n    defmodule\n  ```"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule</code></pre>\n</li>\n</ol>\n"
  end

  test "backtick code fence in list item, closing fince more aligned" do
    result = Earmark.to_html "  1. one\n    ```elixir\n    defmodule\n        ```"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule</code></pre>\n</li>\n</ol>\n"
  end
  
  test "tilde code fence in list item, closing fince idemaligned" do
    result = Earmark.to_html "1. one\n\n    ~~~elixir\n    defmodule\n    ~~~"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule</code></pre>\n</li>\n</ol>\n"

  end
  test "tilde code fence in list item, closing fince less aligned" do
    result = Earmark.to_html "1. one\n\n    ~~~elixir\n    defmodule\n  ~~~"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule</code></pre>\n</li>\n</ol>\n"
  end

  test "tilde code fence in list item, closing fince more aligned" do
    result = Earmark.to_html "  1. one\n    ~~~elixir\n    defmodule\n        ~~~"
    assert result == "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\">    defmodule</code></pre>\n</li>\n</ol>\n"
  end
end
