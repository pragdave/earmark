defmodule BlockTest do
  use ExUnit.Case

  alias Earmark.Line
  alias Earmark.Block


  ############
  # Headings #
  ############

  @tag :now
  test "Setext Heading" do
    result = Block.lines_to_blocks([
                %Line.Blank{},
                %Line.Text{content: "Heading"},
                %Line.SetextUnderlineHeading{level: 1}
                # %Line.Blank{}
             ], filename())

    assert result == [ %Block.Heading{content: "Heading", level: 1} ]
  end

  test "Regular heading" do
    result = Block.lines_to_blocks([ %Line.Heading{content: "Heading", level: 2} ], filename())
    assert result == [ %Block.Heading{content: "Heading", level: 2} ]
  end

  ##########
  # Rulers #
  ##########

  test "Ruler" do
    result = Block.lines_to_blocks([ %Line.Ruler{type: "-"} ], filename())
    assert result == [ %Block.Ruler{type: "-"} ]
  end

  ###############
  # Block Quote #
  ###############

  test "Basic block quote" do
    result = Block.lines_to_blocks([
               %Line.BlockQuote{content: "line 1"},
               %Line.BlockQuote{content: "line 2"}
             ], filename())

    expected = [%Block.BlockQuote{blocks: [%Block.Para{lines: ["line 1", "line 2"]}]}]
    assert result == expected
  end

  test "Block quote where continuation lines don't start >" do
    result = Block.lines_to_blocks([
               %Line.BlockQuote{content: "line 1"},
               %Line.Text{content: "line 2"}
             ], filename())

    expected = [%Block.BlockQuote{blocks: [%Block.Para{lines: ["line 1", "line 2"]}]}]
    assert result == expected
  end


  ########
  # Code #
  ########

  test "simple indented code" do
    result = Block.lines_to_blocks([
                  %Line.Indent{level: 1, content: "line 1"},
                  %Line.Indent{level: 1, content: " line 2"},
                  %Line.Blank{},
                  %Line.Indent{level: 1, content: " line 3"},
                  %Line.Indent{level: 1, content: "line 4"}
             ], filename())

    expected = [%Block.Code{language: nil,
                            lines: ["line 1", " line 2", "", " line 3", "line 4"]}]
    assert result == expected
  end

  test "indented code at multiple levels" do
    result = Block.lines_to_blocks([
                  %Line.Indent{level: 1, content: "line 1"},
                  %Line.Indent{level: 1, content: "  line 2"},
                  %Line.Indent{level: 2, content: "line 3"},
                  %Line.Indent{level: 2, content: "  line 4"}
             ], filename())

    expected = [%Block.Code{language: nil,
                            lines: ["line 1", "  line 2", "    line 3", "      line 4"]}]
    assert result == expected
  end

  test "fenced code with ~~~" do
    result = Block.lines_to_blocks([
                  %Line.Fence{delimiter: "~~~", language: "elixir"},
                  %Line.Text{content: "line 1", line: "line 1"},
                  %Line.Blank{line: ""},
                  %Line.Indent{level: 1, content: "line 2", line: "    line 2"},
                  %Line.Fence{delimiter: "~~~"},
             ], filename())
    expected = [%Block.Code{language: "elixir", lines: ["line 1", "", "    line 2"]}]
    assert result == expected
  end

  test "fenced code ignores opposite fence" do
    result = Block.lines_to_blocks([
                  %Line.Fence{delimiter: "~~~", language: "elixir"},
                  %Line.Fence{delimiter: "```", language: "elixir", line: "``` elixir"},
                  %Line.Text{content: "line 1", line: "line 1"},
                  %Line.Fence{delimiter: "~~~"},
             ], filename())
    expected = [%Block.Code{language: "elixir", lines: ["``` elixir", "line 1"]}]
    assert result == expected
  end

  ##############
  # HTML Block #
  ##############

  test "HTML Block" do
    result = Block.lines_to_blocks([
                  %Line.HtmlOpenTag{tag: "table", line: "<table class='c'>"},
                  %Line.Text{line: "line 1"},
                  %Line.HtmlOpenTag{tag: "pre", line: "<pre>"},
                  %Line.Ruler{line: "line 2"},
                  %Line.HtmlCloseTag{tag: "pre", line: "</pre>"},
                  %Line.Text{line: "line 3"},
                  %Line.HtmlCloseTag{tag: "table", line: "</table>"},
             ], filename())

    expected = [%Block.Html{tag: "table", html:
                 ["<table class='c'>",
                  "line 1",
                  "<pre>",
                  "line 2",
                  "</pre>",
                  "line 3",
                  "</table>"]}]

    assert result == expected
  end

  test "Nested HTML Block" do
    result = Block.lines_to_blocks([
                  %Line.HtmlOpenTag{tag: "table", line: "<table class='c'>"},
                  %Line.Text{line: "line 1"},
                  %Line.HtmlOpenTag{tag: "table", line: "<table>"},
                  %Line.Ruler{line: "line 2"},
                  %Line.HtmlCloseTag{tag: "table", line: "</table>"},
                  %Line.Text{line: "line 3"},
                  %Line.HtmlCloseTag{tag: "table", line: "</table>"},
             ], filename())

    expected = [%Block.Html{tag: "table", html:
                 ["<table class='c'>",
                  "line 1",
                  "<table>",
                  "line 2",
                  "</table>",
                  "line 3",
                  "</table>"]}]

    assert result == expected
  end


  test "HTML comment on one line" do
    result = Block.lines_to_blocks([
                  %Line.HtmlComment{line: "<!-- xx -->", complete: true}
             ], filename())
    expected = [ %Block.HtmlOther{html: [ "<!-- xx -->" ]}]

    assert result == expected
  end

  test "HTML comment on multiple lines" do
    result = Block.lines_to_blocks([
                  %Line.HtmlComment{line: "<!-- ", complete: false},
                  %Line.Indent{level: 2, line: "xxx"},
                  %Line.Text{line: "-->"}
             ], filename())
    expected = [ %Block.HtmlOther{html: ["<!-- ", "xxx", "-->"]}]

    assert result == expected
  end

  ##################
  # ID definitions #
  ##################

  test "Basic ID definition" do
    result = Block.lines_to_blocks([
                  %Line.IdDef{id: "id1", url: "url1", title: "title1"}
             ], filename())

    assert result == [%Block.IdDef{id: "id1", title: "title1", url: "url1"}]
  end

  test "ID definition with title on next line" do
    result = Block.lines_to_blocks([
                  %Line.IdDef{id: "id1", url: "url1"},
                  %Line.Text{content: "  (title1)"}
             ], filename())

    assert result == [%Block.IdDef{id: "id1", title: "title1", url: "url1"}]
  end

  test "ID definition with no title and no title on next line" do
    result = Block.lines_to_blocks([
                  %Line.IdDef{id: "id1", url: "url1"},
                  %Line.Text{content: "  not title1", line: "  not title1"}
             ], filename())

    assert result == [
        %Block.IdDef{id: "id1", title: nil, url: "url1"},
        %Block.Para{lines: [ "  not title1" ]}
    ]
  end

  ################################################
  # IALs get associated with the preceding block #
  ################################################

  test "IAL gets associated with previous block" do
    result = Block.lines_to_blocks([
                  %Line.Text{line: "line", content: "line"},
                  %Line.Ial{attrs: ".a1 .a2"},
                  %Line.Text{content: "another", line: "another"}
             ], filename())

    assert result == [
        %Block.Para{lines: [ "line" ], attrs: ".a1 .a2"},
        %Block.Para{lines: [ "another" ], attrs: nil}
    ]
  end

  ######################################################
  # Test that we correctly accumulate the definitions  #
  ######################################################

  test "Accumulate basic ID definition" do
    {blocks, refs } = Block.parse([
                  %Line.IdDef{id: "id1", url: "url1", title: "title1"}
             ], filename())

    defn = %Block.IdDef{id: "id1", title: "title1", url: "url1"}
    assert blocks == [defn]
    assert refs == ([{ "id1", defn}] |> Enum.into(Map.new))
  end

  test "ID definition nested in list" do
    { blocks, refs } = Block.parse([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Indent{level: 1, content: "[id1]: url1  (title1)"},
             ], filename())

    defn = %Block.IdDef{id: "id1", title: "title1", url: "url1"}

    expected = [ %Block.List{ type: :ul, blocks: [
       %Block.ListItem{type: :ul, spaced: false, blocks: [
               %Block.Para{lines: ["line 1"]},
               defn
    ]}]}]

    assert blocks == expected
    assert refs == ([{ "id1", defn}] |> Enum.into(Map.new))
  end

  defp filename do
    "some name"
  end
end
