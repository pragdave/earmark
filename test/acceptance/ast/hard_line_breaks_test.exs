defmodule Acceptance.Ast.HardLineBreaksTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]

  describe "gfm" do 
    test "hard line breaks are enabled" do 
      markdown = "line 1\nline 2\\\nline 3"
      html     = "<p>line 1\nline 2<br />line 3</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "hard line breaks are enabled only inside paras" do 
      markdown = "line 1\nline 2\\\n\nline 3"
      html     = "<p>line 1\nline 2\\</p>\n<p>line 3</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "hard line breaks are not enabled at the end" do 
      markdown = "line 1\nline 2\\\n"
      html     = "<p>line 1\nline 2\\</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "no gfm" do 
    test "hard line breaks are not enabled" do 
      markdown = "line 1\nline 2\\\nline 3"
      html     = "<p>line 1\nline 2\\\nline 3</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, gfm: false) == {:ok, [ast], messages}
    end

    test "hard line breaks are enabled only inside paras" do 
      
      markdown = "line 1\nline 2\\\n\nline 3"
      html     = "<p>line 1\nline 2\\</p>\n<p>line 3</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, gfm: false) == {:ok, ast, messages}
    end

    test "hard line breaks are not enabled at the end" do 
      
      markdown = "line 1\nline 2\\\n"
      html     = "<p>line 1\nline 2\\</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, gfm: false) == {:ok, [ast], messages}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
