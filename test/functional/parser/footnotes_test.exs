defmodule Functional.Parser.FootnotesTest do
  use ExUnit.Case

  alias Earmark.Block
  alias Earmark.Options


  describe "Defined" do
    @vanilla """
    foo[^1]

    [^1]: bar baz
    """
    test "Vanilla Footnote" do
      assert parse(@vanilla) == {[%Block.Para{attrs: nil, lnb: 1, lines: ["foo[^1]"]},
        %Block.FnList{attrs: ".footnotes", lnb: 3,
         blocks: [%Block.FnDef{attrs: nil, lnb: 3,
           blocks: [%Block.Para{attrs: nil, lnb: 3, lines: ["bar baz"]}],
           id: "1", number: 1}]}], []}
    end

    @li_fn """
    2. foo[^1]

    [^1]: bar baz
    """
    test "List Item Footnote" do
      assert parse(@li_fn) == {[
        %Earmark.Block.List{
          lnb: 1,
          attrs: nil,
          blocks: [%Earmark.Block.ListItem{attrs: nil, lnb: 1,
            blocks: [%Earmark.Block.Para{attrs: nil, lnb: 1, lines: ["foo[^1]"]}],
            bullet: "2.",
            spaced: false,
            type: :ol}],
        start: ~s{ start="2"},
        type: :ol},
      %Earmark.Block.FnList{attrs: ".footnotes", blocks: [%Earmark.Block.FnDef{attrs: nil, lnb: 3, blocks: [%Earmark.Block.Para{attrs: nil, lnb: 3, lines: ["bar baz"]}], id: "1", number: 1}], lnb: 3}], []}
    end

  end

  describe "Undefined" do
    @shorter_vanilla """
    foo[^1]

    [^1]: bar
    """
    test "Shorter Vanilla is not a Footnote" do
      assert parse(@shorter_vanilla) ==
      {[%Earmark.Block.Para{attrs: nil, lnb: 1, lines: ["foo[^1]"]},
        %Earmark.Block.IdDef{attrs: nil, lnb: 3, id: "^1", title: "", url: "bar"}], [{:error, 1, "footnote 1 undefined, reference to it ignored"}]}

    end

    @undefined_fn """
    foo[^1]

    [^2]: bar baz
    """
    test "Footnote" do
      assert parse(@undefined_fn) == {[%Earmark.Block.Para{attrs: nil, lines: ["foo[^1]"], lnb: 1}], [{:error, 1, "footnote 1 undefined, reference to it ignored"}]}

    end
  end

  defp parse(str) do
    {blocks, context} = Earmark.Parser.parse_markdown(str, %Options{footnotes: true})
    {blocks, context.options.messages}
  end
end

# SPDX-License-Identifier: Apache-2.0
