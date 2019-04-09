defmodule MyTestRenderer do
  use Earmark.HtmlRenderer

  def link(url, text), do: ~s[<a href="#{url}" class="custom-link">#{text}</a>]

  def link(url, text, title),
    do: ~s[<a href="#{url}" title="#{title}" class="custom-link">#{text}</a>]
end

defmodule RendererTest do
  use ExUnit.Case

  describe "Renderer functions can be overridden" do
    test "link/2" do
      assert MyTestRenderer.link("/hello", "world") ==
               ~s[<a href="/hello" class="custom-link">world</a>]
    end

    test "link/3" do
      assert MyTestRenderer.link("/hello", "world", "earth") ==
               ~s[<a href="/hello" title="earth" class="custom-link">world</a>]
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
