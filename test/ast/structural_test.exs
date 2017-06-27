defmodule Acceptance.StructuralTest do
  use ExUnit.Case

  describe "complex rendering inside tables:" do 
    test "table with link with inline ial, no errors" do 
      
      markdown = "|a|b|c|\n|d|e|[link](url){:target=blank}|"
      # html     = "<table>\n<colgroup>\n<col>\n<col>\n<col>\n</colgroup>\n<tr>\n<td style=\"text-align: left\">a</td><td style=\"text-align: left\">b</td><td style=\"text-align: left\">c</td>\n</tr>\n<tr>\n<td style=\"text-align: left\">d</td><td style=\"text-align: left\">e</td><td style=\"text-align: left\"><a href=\"url\" target=\"blank\">link</a></td>\n</tr>\n</table>\n" 
      ast = {"table", [], [{"colgroup", [], [{"col", [], []}, {"col", [], []}, {"col", [], []}]},  {"tr", [],   [{"td", [{"style", "text-align: left"}], ["a"]},    {"td", [{"style", "text-align: left"}], ["b"]},    {"td", [{"style", "text-align: left"}], ["c"]}]},  {"tr", [],   [{"td", [{"style", "text-align: left"}], ["d"]},    {"td", [{"style", "text-align: left"}], ["e"]},    {"td", [{"style", "text-align: left"}],     [{"a", [{"href", "url"}, {"target", "blank"}], ["link"]}]}]}]}
      messages = []

      assert Earmark.Interface.html(markdown) == {:ok, ast, messages}
    end

    test "table with link with inline ial, errors" do 
      
      markdown = "|a|b|c|\n|d|e|[link](url){:target=blank xxx}|"
      # html     = "<table>\n<colgroup>\n<col>\n<col>\n<col>\n</colgroup>\n<tr>\n<td style=\"text-align: left\">a</td><td style=\"text-align: left\">b</td><td style=\"text-align: left\">c</td>\n</tr>\n<tr>\n<td style=\"text-align: left\">d</td><td style=\"text-align: left\">e</td><td style=\"text-align: left\"><a href=\"url\" target=\"blank\">link</a></td>\n</tr>\n</table>\n" 
      ast = {"table", [], [{"colgroup", [], [{"col", [], []}, {"col", [], []}, {"col", [], []}]},  {"tr", [],   [{"td", [{"style", "text-align: left"}], ["a"]},    {"td", [{"style", "text-align: left"}], ["b"]},    {"td", [{"style", "text-align: left"}], ["c"]}]},  {"tr", [],   [{"td", [{"style", "text-align: left"}], ["d"]},    {"td", [{"style", "text-align: left"}], ["e"]},    {"td", [{"style", "text-align: left"}],     [{"a", [{"href", "url"}, {"target", "blank"}], ["link"]}]}]}]}
      messages = [{:warning, 2, "Illegal attributes [\"xxx\"] ignored in IAL"}]

      assert Earmark.Interface.html(markdown) == {:error, ast, messages}
    end
  end
end
