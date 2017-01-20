defmodule FootnoteTest do
  use ExUnit.Case

  alias Earmark.Parser
  alias Earmark.Inline
  alias Earmark.Block
  alias Earmark.Line

  def test_footnotes do
    [ {"fn-a", %Block.FnDef{id: "fn-a", number: 1}} ]
    |> Enum.into(Map.new)
  end

  def options do
    %Earmark.Options{footnotes: true, file: filename()}
  end

  def context do
    ctx = put_in(%Earmark.Context{}.options, options())
    ctx = put_in(ctx.footnotes, test_footnotes())
    Inline.update_context(ctx)
  end

  def convert(string) do
    Inline.convert(string, context())
  end

  test "handles FnDef blocks without Footnotes enabled" do
    lines = ["This is a footnote[^1].", "", "[^1]: This is the content."]
    Earmark.as_html!(lines, put_in(%Earmark.Options{}.footnotes, false))
    # expected: not crashing
  end

  test "handles text without footntoes when Footnotes enabled" do
    lines = ["This is some regular text"]
    Earmark.as_html!(lines, options())
  end

  test "basic footnote link" do
    result = convert(~s{a footnote[^fn-a] in text})
    assert result == ~s[a footnote<a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">1</a> in text]
  end

  test "pulls one-line footnote bodies" do
    result = Block.lines_to_blocks([ %Line.FnDef{id: "some-fn", content: "This is a footnote."} ], options())
    assert result == {[%Block.FnDef{id: "some-fn", blocks: [%Block.Para{lines: ["This is a footnote."]}]}], options()}
  end

  test "pulls multi-line footnote bodies" do
    result = Block.lines_to_blocks([
                %Line.FnDef{id: "some-fn", content: "This is a multi-line"},
                %Line.Text{content: "footnote example.", line: "footnote example."}
             ], options())
    expected = {[%Block.FnDef{id: "some-fn", blocks: [
                  %Block.Para{lines: ["This is a multi-line", "footnote example."]}
                ]}], options()}
    assert result == expected
  end

  test "handles multi-paragraph footnote bodies" do
    lines = ["This is a footnote[^fn-1]",
             "",
             "[^fn-1]: line 1",
             "line 2",
             "",
             "    Para 2 line 1",
             "    Para 2 line 2",
             "",
             "    * List Item 1",
             "      List Item 1 Cont",
             "    * List Item 2"
             ]

    {result, _, _} = Parser.parse(lines)
    expected = [%Block.Para{lnb: 1, attrs: nil, lines: ["This is a footnote[^fn-1]"]},
		%Block.Para{lnb: 3, attrs: nil, lines: ["[^fn-1]: line 1", "line 2"]},
            	%Block.Code{lnb: 6, attrs: nil, language: nil, lines: ["Para 2 line 1", "Para 2 line 2", "",
								       "* List Item 1", "  List Item 1 Cont", "* List Item 2"]
		}]
    assert result == expected

    html = Earmark.as_html!(lines, put_in(%Earmark.Options{}.footnotes, true))
    expected_html = """
    <p>This is a footnote<a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">1</a></p>
    <div class="footnotes">
    <hr>
    <ol>
    <li id="fn:1"><p>line 1
    line 2</p>
    <p>Para 2 line 1
    Para 2 line 2</p>
    <ul>
    <li>List Item 1
      List Item 1 Cont
    </li>
    <li>List Item 2
    </li>
    </ul>
    <p><a href="#fnref:1" title="return to article" class="reversefootnote">&#x21A9;</a></p>
    </li>
    </ol>

    </div>
    """
    assert "#{html}\n" == expected_html
  end

  test "uses a starting footnote number" do
    para = %Block.Para{lines: ["line 1[^ref-1] and", "line 2[^ref-2]."]}
    text = [para,
            %Block.FnDef{id: "ref-2", blocks: [%Block.Para{lines: ["ref 2"]}]},
            %Block.FnDef{id: "ref-1", blocks: [%Block.Para{lines: ["ref 1"]}]}]
    opts = put_in(options().footnote_offset, 3)
    { blocks, footnotes, _ } = Parser.handle_footnotes(text, opts, &Enum.map/2)
    output_fnotes = [%Block.FnDef{id: "ref-1", number: 3, blocks: [%Block.Para{lines: ["ref 1"]}]},
                     %Block.FnDef{id: "ref-2", number: 4, blocks: [%Block.Para{lines: ["ref 2"]}]}]
    expected_blocks = [para, %Block.FnList{blocks: output_fnotes}]
    assert blocks == expected_blocks
    expected_fnotes = Enum.map(output_fnotes, &({&1.id, &1})) |> Enum.into(Map.new)
    assert footnotes == expected_fnotes
  end

  test "parses footnote content" do
    {blocks, _, _} = Parser.parse(["para[^ref-id]", "", "[^ref-id]: line 1", "line 2", "line 3", "", "para"], options(), false)
    {blocks, footnotes, _} = Parser.handle_footnotes(blocks, options(), &Enum.map/2)
    fn_content = [%Earmark.Block.Para{lnb: 3, lines: ["line 1", "line 2", "line 3"]}]
    fn_def = %Earmark.Block.FnDef{lnb: 3, id: "ref-id", number: 1, blocks: fn_content }
    assert blocks == [%Earmark.Block.Para{lnb: 1, lines: ["para[^ref-id]"]},
                      %Earmark.Block.Para{lnb: 7, lines: ["para"]},
                      %Earmark.Block.FnList{lnb: 3, blocks: [fn_def]}
                     ]
    expect = Map.new |> Map.put("ref-id", fn_def)
    assert footnotes == expect
  end

  test "renders footnotes" do
    body = """
    A line with[^ref-a] two references[^ref-b].

    [^ref-b]: Ref B.
    [^ref-a]: Ref A.
    """
    result = Earmark.as_html!(body, put_in(%Earmark.Options{}.footnotes, true))
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

  defp filename do
    "file name"
  end
end
