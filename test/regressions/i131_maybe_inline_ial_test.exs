defmodule Regressions.I131MaybeInlineIalTest do
  use ExUnit.Case
  
  import Support.Helpers, only: [as_html!: 1]

  @block_level """
  [link](url)
  {: .shiny }
  """

  test "block level IAL on para" do
    assert as_html!(@block_level) == ~s{<p class="shiny"><a href="url">link</a></p>\n}
  end

  @inline_level """
  [link](url){: .shiny }
  """
  test "inline level IAL on link" do
    assert as_html!(@inline_level) == ~s{<p><a href="url" class="shiny">link</a></p>\n}
  end
end
