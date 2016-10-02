defmodule Regressions.I093LastLiNotWrappedInPTest do
  use ExUnit.Case

  @vanilla_list """
  * a

  * b
  """
  test "vanilla list" do 
    assert "<ul>\n<li><p>a</p>\n</li>\n<li><p>b</p>\n</li>\n</ul>\n" == Earmark.to_html( @vanilla_list )
  end

  test "parsing the vanilla list does not space the last item - Renderer's job for now" do 
    expected = 
    {[%Earmark.Block.List{attrs: nil,
       blocks: [%Earmark.Block.ListItem{attrs: nil,
         blocks: [%Earmark.Block.Para{attrs: nil, lines: ["a"]}],
         spaced: true, type: :ul},
       %Earmark.Block.ListItem{attrs: nil,
        blocks: [%Earmark.Block.Para{attrs: nil, lines: ["b"]}],
        spaced: false, type: :ul}], type: :ul}], %{}}

     assert expected == @vanilla_list |> String.split(~r{\n}) |>Earmark.Parser.parse()
  end

  @longer """
  * a

  * b

  Meaningless Text
  """
  test "not at EOF" do 
    assert "<ul>\n<li><p>a</p>\n</li>\n<li><p>b</p>\n</li>\n</ul>\n<p>Meaningless Text</p>\n" == Earmark.to_html( @longer )
  end
end
