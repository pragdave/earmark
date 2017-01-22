defmodule ListTest do
  use ExUnit.Case

  alias Earmark.Line
  alias Earmark.Block

  # TODO: These tests are heavily unorthogonal, seperate functional from integration tests
  test "Basic UL" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"}
             ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false, bullet: "*"}
    ]}], options()}
    assert result == expected
  end

  test "Multiline UL" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Text{content: "line 2"}
             ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{type: :ul, blocks: [
                %Block.Para{lines: ["line 1", "line 2"]}], spaced: false, bullet: "*"}
    ]}], options()}
    assert result == expected
  end

  test "UL containing two paras" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Indent{content: "line 2", level: 1},
               %Line.Blank{}
             ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{blocks: [%Block.Para{lines: ["line 1"]},
                                %Block.Para{lines: ["line 2"], lnb: 2}],
                                spaced: false, type: :ul, bullet: "*"}
    ]}], options()}
    assert result == expected
  end

  test "UL containing two paras where the second is only indented 2 spaces" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Text{content: "  line 2", line: "  line 2"},
               %Line.Blank{}
             ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{blocks: [%Block.Para{lines: ["line 1"]},
                                %Block.Para{lines: ["  line 2"], lnb: 2}],
                                spaced: false, type: :ul, bullet: "*"}
    ]}], options()}
    assert result == expected
  end

  test "Multiline UL followed by a blank line" do
    result = Block.lines_to_blocks([
               %Line.ListItem{bullet: "*", content: "line 1"},
               %Line.Text{content: "line 2"},
               %Line.Blank{}
             ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{type: :ul, blocks: [
                 %Block.Para{lines: ["line 1", "line 2"]}], spaced: false, bullet: "*"}
    ]}], options()}
    assert result == expected
  end

  test "Two adjacent UL items, the first is not spaced" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.ListItem{type: :ul, bullet: "*", content: "line 2"},
             ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
       %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false, bullet: "*"},
       %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 2"]}], spaced: false, bullet: "*"},
    ]}], options()}
    assert result == expected
  end

  test "Two UL items with a blank line between are both spaced" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.ListItem{type: :ul, bullet: "*", content: "line 2"},
             ], options())
    expected = {[ %Block.List{ type: :ul, blocks: [
       %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: true, bullet: "*"},
       %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 2"]}], spaced: true, bullet: "*"},
    ]}], options()}
    assert result == expected
  end

  test "Two UL items followed by a non-indented paragraph" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.ListItem{type: :ul, bullet: "*", content: "line 2"},
               %Line.Blank{},
               %Line.Text{content: "para", line: "para"}
             ], options())
    expected = {[
       %Block.List{ type: :ul, blocks: [
         %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false, bullet: "*"},
         %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 2"]}], spaced: false, bullet: "*"},
       ]},
       %Block.Para{lines: ["para"]},
    ], options()}
    assert result == expected
  end

  test "Code nested in list" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1", lnb: 1},
               %Line.Blank{ lnb: 1},
               %Line.Indent{level: 2, content: "code 1", lnb: 1},
               %Line.Indent{level: 3, content: "code 2", lnb: 1},
               %Line.Blank{ lnb: 1},
               %Line.Indent{level: 1, content: "line 2", lnb: 1},
             ], options())

    expected = {[ %Block.List{ lnb: 1, type: :ul, blocks: [
       %Block.ListItem{lnb: 1, type: :ul, blocks: [
               %Block.Para{lines: ["line 1"], lnb: 1},
               %Block.Code{language: nil, lines: ["code 1", "    code 2"], lnb: 3},
               %Block.Para{lines: ["line 2"], lnb: 6}], spaced: false, bullet: "*"}
    ]}], options(1)}

    assert result == expected
  end

  # OLs are handled by the same code as ULs, so to save time, we really just
  # need a single smoke test. If this changes in future, we'll need to
  # relook at this

  test "Basic OL" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ol, bullet: "1.", content: "line 1"}
             ], options())
    expected = {[ %Block.List{ type: :ol, blocks: [
         %Block.ListItem{type: :ol, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false, bullet: "1."}
    ]}], options()}
    assert result == expected
  end



  test "Simple list render" do
    result = Earmark.as_html!(["* one", "* two"])
    expected = """
    <ul>
    <li>one\n</li>
    <li>two\n</li>
    </ul>
    """
    assert result == expected
  end


  test "Indented list render" do
    result = Earmark.as_html!(["   * one", "   * two"])
    expected = """
    <ul>
    <li>one\n</li>
    <li>two\n</li>
    </ul>
    """
    assert result == expected
  end

  test "Initial indentation of * taken into account when looking at body" do
    result = Earmark.as_html!([
    "   * one",
    "     one.one",
    "   * two"
    ])

    expected = """
    <ul>
    <li>one\n one.one\n</li>
    <li>two\n</li>
    </ul>
    """
    assert result == expected
  end

  defp filename do
    "some file"
  end

  defp options(line \\ 0) do
    %Earmark.Options{file: filename(), line: line}
  end
end
