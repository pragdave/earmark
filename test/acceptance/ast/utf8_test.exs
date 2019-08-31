defmodule Acceptance.Ast.Utf8Test do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 2, parse_html: 1]

  describe "valid rendering" do
    test "pure link" do
      markdown = " foo (http://test.com)… bar"
      html = "<p> foo (<a href=\"http://test.com\">http://test.com</a>)… bar</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, pure_links: true) == {:ok, [ast], messages}
    end
  end
end
