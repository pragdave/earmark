defmodule Acceptance.Ast.Utf8Test do
  use ExUnit.Case
  import Support.Helpers, only: [as_html!: 2]

  describe "valid rendering" do
    test "pure link" do
      markdown = " foo (http://test.com)… bar"
      assert html = as_html!(markdown, pure_links: true)
      assert String.valid?(html)
      assert html == "<p> foo (<a href=\"http://test.com\">http://test.com</a>)… bar</p>\n"
    end
  end
end
