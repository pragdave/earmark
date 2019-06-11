defmodule FootnoteTest do
  use ExUnit.Case

  alias Earmark.Block
  alias Earmark.Context
  alias Earmark.Inline
  alias Earmark.Line
  alias Earmark.Parser

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
    Context.update_context(ctx)
  end

  def convert(string) do
    Inline.convert(string, 0, context())
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
    assert result.value == ~s[a footnote<a href="#fn:1" id="fnref:1" class="footnote" title="see footnote">1</a> in text]
  end

  test "pulls one-line footnote bodies" do
    result = lines_to_blocks([ %Line.FnDef{id: "some-fn", content: "This is a footnote."} ], options())
    assert result == {[%Block.FnDef{id: "some-fn", blocks: [%Block.Para{lines: ["This is a footnote."]}]}], options()}
  end

  test "pulls multi-line footnote bodies" do
    result = lines_to_blocks([
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


  test "parses footnote content" do
    markdown = "para[^ref-id]\n\n[^ref-id]: line 1\nline 2\nline 3\n\npara"
    html     = "<p>para<a href=\"#fn:1\" id=\"fnref:1\" class=\"footnote\" title=\"see footnote\">1</a></p>\n<p>para</p>\n<div class=\"footnotes\">\n<hr>\n<ol>\n<li id=\"fn:1\"><p>line 1\nline 2\nline 3&nbsp;<a href=\"#fnref:1\" title=\"return to article\" class=\"reversefootnote\">&#x21A9;</a></p>\n</li>\n</ol>\n\n</div>"
    assert Earmark.as_html!(markdown, footnotes: true) == html
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

  defp lines_to_blocks(lines, options) do
    {blks, _links, opts} = Parser.parse_lines(lines, options)
    {blks, opts}
  end
end

# SPDX-License-Identifier: Apache-2.0
