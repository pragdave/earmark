defmodule Acceptance.Ast.TableTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]
  import EarmarkAstDsl
  
  describe "complex rendering inside tables:" do 

    test "simple table" do 
      markdown = "|a|b|\n|d|e|"
      html     = "<table>\n<tbody>\n<tr>\n<td style=\"text-align: left;\">a</td><td style=\"text-align: left;\">b</td>\n</tr>\n<tr>\n<td style=\"text-align: left;\">d</td><td style=\"text-align: left;\">e</td>\n</tr>\n</tbody>\n</table>\n" 
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
      
    end

    test "table with link with inline ial, no errors" do 
      markdown = "|a|b|c|\n|d|e|[link](url){:target=blank}|"
      html     = "<table>\n<tbody>\n<tr>\n<td style=\"text-align: left;\">a</td><td style=\"text-align: left;\">b</td><td style=\"text-align: left;\">c</td>\n</tr>\n<tr>\n<td style=\"text-align: left;\">d</td><td style=\"text-align: left;\">e</td><td style=\"text-align: left;\"><a href=\"url\" target=\"blank\">link</a></td>\n</tr>\n</tbody>\n</table>\n" 
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "table with link with inline ial, errors" do 
      markdown = "|a|b|c|\n|d|e|[link](url){:target=blank xxx}|"
      html     = "<table>\n<tbody>\n<tr>\n<td style=\"text-align: left;\">a</td><td style=\"text-align: left;\">b</td><td style=\"text-align: left;\">c</td>\n</tr>\n<tr>\n<td style=\"text-align: left;\">d</td><td style=\"text-align: left;\">e</td><td style=\"text-align: left;\"><a href=\"url\" target=\"blank\">link</a></td>\n</tr>\n</tbody>\n</table>\n" 
      ast      = parse_html(html)
      messages = [{:warning, 2, "Illegal attributes [\"xxx\"] ignored in IAL"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "table with header" do
      markdown = "|alpha|beta|\n|-|-:|\n|1|2|"
      html     = "<table>\n<thead>\n<tr>\n<th style=\"text-align: left;\">alpha</th><th style=\"text-align: right;\">beta</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td style=\"text-align: left;\">1</td><td style=\"text-align: right;\">2</td>\n</tr>\n</tbody>\n</table>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "table with header inside context" do
      markdown = "before\n\n|alpha|beta|\n|-|-:|\n|1|2|\nafter"
      html     = "<p>before</p>\n<table>\n<thead>\n<tr>\n<th style=\"text-align: left;\">alpha</th><th style=\"text-align: right;\">beta</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td style=\"text-align: left;\">1</td><td style=\"text-align: right;\">2</td>\n</tr>\n</tbody>\n</table>\n<p>after</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "Tables and IAL" do
    test "as mentioned above" do
      markdown = "|a|b|\n|d|e|\n{:#the-table}"
      html     = "<table id=\"the-table\"><tbody>\n<tr>\n<td style=\"text-align: left;\">a</td><td style=\"text-align: left;\">b</td>\n</tr>\n<tr>\n<td style=\"text-align: left;\">d</td><td style=\"text-align: left;\">e</td>\n</tr>\n</tbody>\n</table>\n" 
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "GFM Tables" do
    test "do not need spaces around mid `\|`" do
      markdown = "a|b\n-|-\nd|e\n"
      html     = "<table>\n<thead>\n<tr>\n<th style=\"text-align: left;\">a</th><th style=\"text-align: left;\">b</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td style=\"text-align: left;\">d</td><td style=\"text-align: left;\">e</td>\n</tr>\n</tbody>\n</table>\n" 
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, gfm_tables: true) == {:ok, [ast], messages}
    end

    test "do not need spaces around mid `\|` but w/o gfm_tables this is no good" do
      markdown = "a|b\n-|-\nd|e\n"
      html     = "<p>a|b\n-|-\nd|e</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, gfm_tables: false) == {:ok, [ast], messages}
    end

    test "however a header line needs to be used" do
      markdown = "a|b\nd|e\n"
      html     = "<p>a|b\nd|e</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, gfm_tables: true) == {:ok, [ast], messages}
    end
  end

  describe "The order of things (Vorta and Jem'Hadar I guess)" do
    test "table celles are in the correct order" do
      markdown = """
      | What              |
      | ----------------- |
      | This part is fine |
      | This is `broken`  |
      """
      ast = table(["This part is fine", { "This is ", tag(:code, "broken", class: :inline) }], head: ["What"])
      assert as_ast(markdown) == {:ok, [ast], []}
    end

    test "minimized example" do
      markdown = "|zero|\n|alpha *beta*|"
      ast = table(["zero", { "alpha ", tag(:em, "beta") }])

      assert as_ast(markdown) == {:ok, [ast], []}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
