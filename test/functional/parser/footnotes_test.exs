defmodule Functional.Parser.FootnotesTest do
  use ExUnit.Case

  alias Earmark.Block
  alias Earmark.Context
  alias Earmark.Options

  describe "Defined" do
    @vanilla """
    foo[^1]

    [^1]: bar baz
    """
    test "Vanilla Footnote" do
      assert parse(@vanilla) == {[%Block.Para{attrs: nil, lines: ["foo[^1]"]},
        %Block.FnList{attrs: ".footnotes",
         blocks: [%Block.FnDef{attrs: nil,
           blocks: [%Block.Para{attrs: nil, lines: ["bar baz"]}],
           id: "1", number: 1}]}], []}
    end

    @li_fn """
    2. foo[^1]

    [^1]: bar baz
    """
    test "List Item Footnote" do
      assert parse(@li_fn) == {[
        %Earmark.Block.List{
          attrs: nil,
          blocks: [%Earmark.Block.ListItem{attrs: nil,
            blocks: [%Earmark.Block.Para{attrs: nil, lines: ["foo[^1]"]}],
            bullet: "2.",
            spaced: false,
            type: :ol}],
        start: ~s{ start="2"},
        type: :ol},
      %Earmark.Block.FnList{attrs: ".footnotes", blocks: [%Earmark.Block.FnDef{attrs: nil, blocks: [%Earmark.Block.Para{attrs: nil, lines: ["bar baz"]}], id: "1", number: 1}]}], []}
    end

  end

  describe "Undefined" do
    @shorter_vanilla """
    foo[^1]

    [^1]: bar
    """
    test "Shorter Vanilla is not a Footnote" do
      assert parse(@shorter_vanilla) == {[%Earmark.Block.Para{attrs: nil, lines: ["foo[^1]"]}, %Earmark.Block.IdDef{attrs: nil, id: "^1", title: "", url: "bar"}], [{:error, 99999, "footnote 1 undefined, reference to it ignored"}]}

    end

    @undefined_fn """
    foo[^1]

    [^2]: bar baz
    """
    test "Footnote" do
      assert parse(@undefined_fn) == {[%Earmark.Block.Para{attrs: nil, lines: ["foo[^1]"]}], [{:error, 99999, "footnote 1 undefined, reference to it ignored"}]}

    end
  end

  defp parse(str) do
    with {blocks, %Context{options: %Options{messages: messages}}} = Earmark.parse(str, %Options{footnotes: true}) do
      {blocks, messages}
    end
  end
end
