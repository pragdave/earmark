defmodule Ast.TableTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1]

  describe "complex rendering inside tables:" do

    test "simple table" do
      markdown = "|a|b|\n|d|e|"
      ast = {"table", [],  [    {"colgroup", [], [{"col", [], []}, {"col", [], []}]},    {"tr", [],     [       {"td", [{"style", "text-align: left"}], ["a"]},       {"td", [{"style", "text-align: left"}], ["b"]}     ]},    {"tr", [],     [       {"td", [{"style", "text-align: left"}], ["d"]},       {"td", [{"style", "text-align: left"}], ["e"]}     ]}  ]}
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}

    end

    test "table with link with inline ial, no errors" do

      markdown = "|a|b|c|\n|d|e|[link](url){:target=blank}|"
      ast = {"table", [],  [    {"colgroup", [], [{"col", [], []}, {"col", [], []}, {"col", [], []}]},    {"tr", [],     [       {"td", [{"style", "text-align: left"}], ["a"]},       {"td", [{"style", "text-align: left"}], ["b"]},       {"td", [{"style", "text-align: left"}], ["c"]}     ]},    {"tr", [],     [       {"td", [{"style", "text-align: left"}], ["d"]},       {"td", [{"style", "text-align: left"}], ["e"]},       {"td", [{"style", "text-align: left"}],        [{"a", [{"href", "url"}, {"target", "blank"}], ["link"]}]}     ]}  ]}
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "table with link with inline ial, errors" do

      markdown = "|a|b|c|\n|d|e|[link](url){:target=blank xxx}|"
      ast = {"table", [],  [    {"colgroup", [], [{"col", [], []}, {"col", [], []}, {"col", [], []}]},    {"tr", [],     [       {"td", [{"style", "text-align: left"}], ["a"]},       {"td", [{"style", "text-align: left"}], ["b"]},       {"td", [{"style", "text-align: left"}], ["c"]}     ]},    {"tr", [],     [       {"td", [{"style", "text-align: left"}], ["d"]},       {"td", [{"style", "text-align: left"}], ["e"]},       {"td", [{"style", "text-align: left"}],        [{"a", [{"href", "url"}, {"target", "blank"}], ["link"]}]}     ]}  ]}
      messages = [{:warning, 2, "Illegal attributes [\"xxx\"] ignored in IAL"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end

    test "table with header" do
      markdown = "|alpha|beta|\n|-|-:|\n|1|2|"
      ast = {"table", [],  [    {"colgroup", [], [{"col", [], []}, {"col", [], []}]},    {"thead", [],     [       {"tr", [],        [          {"th", [{"style", "text-align: left"}], ["alpha"]},          {"th", [{"style", "text-align: right"}], ["beta"]}        ]}     ]},    {"tr", [],     [       {"td", [{"style", "text-align: left"}], ["1"]},       {"td", [{"style", "text-align: right"}], ["2"]}     ]}  ]}
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "table with header inside context" do
      markdown = "before\n\n|alpha|beta|\n|-|-:|\n|1|2|\nafter"
      ast = [   {"p", [], ["before"]},   {"table", [],    [      {"colgroup", [], [{"col", [], []}, {"col", [], []}]},      {"thead", [],       [         {"tr", [],          [            {"th", [{"style", "text-align: left"}], ["alpha"]},            {"th", [{"style", "text-align: right"}], ["beta"]}          ]}       ]},      {"tr", [],       [         {"td", [{"style", "text-align: left"}], ["1"]},         {"td", [{"style", "text-align: right"}], ["2"]}       ]}    ]},   {"p", [], ["after"]} ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0