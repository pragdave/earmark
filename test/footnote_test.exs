defmodule FootnoteTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Inline
  alias Earmark.Block
  alias Earmark.Line

  def test_footnotes do
    [ {"fn-a", %Block.FnDef{id: "fn-a", number: 1}} ]
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

  test "basic footnote link" do
    result = convert(~s{a footnote[^fn-a] in text})
    assert result == ~s[a footnote<a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">1</a> in text]
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

  test "parses footnote content" do
    {blocks, _, footnotes} = Parser.parse(["para[^ref-id]", "", "[^ref-id]: line 1", "line 2", "line 3", "", "para"])
    fn_def = %Earmark.Block.FnDef{attrs: nil,
                                  id: "ref-id",
                                  number: 1,
                                  blocks: [%Earmark.Block.Para{attrs: nil, lines: ["line 1", "line 2", "line 3"]}]}
    assert blocks == [%Earmark.Block.Para{lines: ["para[^ref-id]"]},
                      %Earmark.Block.Para{lines: ["para"]},
                      %Earmark.Block.FnList{blocks: [fn_def]}
                     ]
    expect = HashDict.new
             |> HashDict.put("ref-id", fn_def)
    assert footnotes == expect
  end

  test "renders footnotes" do
    body = """
    A line with[^ref-a] two references[^ref-b].

    [^ref-b]: Ref B.
    [^ref-a]: Ref A.
    """
    result = Earmark.to_html(body, put_in(%Earmark.Options{}.footnotes, true))
    expected = """
    <p>A line with<a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">1</a> two references<a href="#fn:2" id="fnref:2" class="footnote" title="see footnote">2</a>.</p>
    <div class="footnotes">
    <hr>
    <ol>
    <li id="fn:1"><p>Ref A.&nbsp;<a href="#fnref:1" title="return to article" class="reversefootnote">&#x21A9;</a></p>
    </li>
    <li id="fn:2"><p>Ref B.&nbsp;<a href="#fnref:2" title="return to article" class="reversefootnote">&#x21A9;</a></p>
    </li>
    </ol>

    </div>
    """
    assert "#{result}\n" == expected
  end

end
