defmodule Acceptance.Html1.ListAndBlockTest do
  use ExUnit.Case
  import Support.Html1Helpers
  
  @moduletag :html1
  describe "Block Quotes in Lists" do
    # Incorrect behavior needs to be fixed with #249 or #304
    test "two spaces" do
      markdown = "- a\n  > b"
      html = construct([
        {:ul, nil, {:li, nil, "a"}},
        {:blockquote, nil, {:p, nil, "b"}}])
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
    test "four spaces" do
      markdown = "- c\n    > d"
      html = construct(
        {:ul, nil, {:li, nil, [{:p, nil, "c"}, {:blockquote, nil, {:p, nil, "d"}}]}})
      messages = []

      assert to_html1(markdown) == {:ok, html, messages}
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
