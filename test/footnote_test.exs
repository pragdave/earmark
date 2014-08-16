defmodule FootnoteTest do
  use ExUnit.Case

  alias Earmark.Inline
  alias Earmark.Block
  alias Earmark.Line

  def test_footnotes do
    [ {"fn-a", %Block.FnDef{id: ""}}
    ]
    |> Enum.into(HashDict.new)
  end

  def context do
    ctx = put_in(%Earmark.Context{}.options.footnotes, true)
    ctx = put_in(ctx.footnotes, test_footnotes)
    Inline.update_context(ctx)
  end

  def convert(string) do
    Inline.convert(string, context)
  end

  test "smoke" do
    result = convert("hello")
    assert result == "hello"
  end

  test "basic footnote link" do
    result = convert(~s{a footnote[^fn-a] in text})
    assert result == ~s[a footnote<a href=\"#fn:1\" id=\"fnref:1\" class="footnote" title="see footnote">1</a> in text]
  end

  test "missing footnote link" do
    str = ~s{a missing footnote[^fn-non-exist].}
    assert str == convert(str)
  end

  test "pulls one-line footnote bodies" do
    result = Block.lines_to_blocks([
                %Line.FnDef{id: "some-fn", content: "This is a footnote."}
             ])
    assert result == [%Block.FnDef{id: "some-fn", blocks: [%Block.Para{lines: ["This is a footnote."]}]}]
  end

  test "pulls multi-line footnote bodies" do
    result = Block.lines_to_blocks([
                %Line.FnDef{id: "some-fn", content: "This is a multi-line"},
                %Line.Text{content: "footnote example.", line: "footnote example."}
             ])
    expected = [%Block.FnDef{id: "some-fn", blocks: [
                  %Block.Para{lines: ["This is a multi-line", "footnote example."]}
                ]}]
    assert result == expected
  end

end
