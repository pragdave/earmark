defmodule Functional.Ast.Renderer.TableRendererTest do
  use ExUnit.Case

  alias Earmark.Ast.Renderer.TableRenderer


  setup do
    {:ok, context: Earmark.Context.update_context}
  end

  describe "rendering a table's rows" do
    test "the proverbial vanilla case", context do
      rows = [
        ~w{alpha beta},
        ~w{it was}
      ]
      aligns = ~w{left center}a
      expected = [
        {"tr", [], [
          {"td", [{"style", "text-align: left;"}], ["alpha"]}, 
          {"td", [{"style", "text-align: center;"}], ["beta"]}, 
        ]},
        {"tr", [], [
          {"td", [{"style", "text-align: left;"}], ["it"]}, 
          {"td", [{"style", "text-align: center;"}], ["was"]}, 
        ]},
      ]

      {ast, context} = TableRenderer.render_rows(rows, 0, aligns, context.context)
      assert ast == expected
    end

    test "yet another proverbial vanilla case", context do
      header = ~w{alpha beta gamma}
      aligns = ~w{left center right}a
      expected = 
        {"thead", [], [
          {"tr", [], [
          {"th", [{"style", "text-align: left;"}], ["alpha"]}, 
          {"th", [{"style", "text-align: center;"}], ["beta"]}, 
          {"th", [{"style", "text-align: right;"}], ["gamma"]}, 
        ]}]}
      {ast, context} = TableRenderer.render_header(header, 0, aligns, context.context)
      assert ast == expected
    end
  end
end
