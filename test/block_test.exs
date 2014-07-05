defmodule BlockTest do
  use ExUnit.Case

  alias Earmark.Line
  alias Earmark.Block
  
  ############
  # Headings #
  ############

  test "Setext Heading" do
    result = Block.lines_to_blocks([
                %Line.Blank{}, 
                %Line.Text{content: "Heading"},
                %Line.SetextUnderlineHeading{level: 1},
                %Line.Blank{}
             ])

    assert result == [ %Block.Heading{content: "Heading", level: 1} ]
  end

  test "Regular heading" do
    result = Block.lines_to_blocks([ %Line.Heading{content: "Heading", level: 2} ])
    assert result == [ %Block.Heading{content: "Heading", level: 2} ]
  end

  ##########
  # Rulers #
  ##########

  test "Ruler" do
    result = Block.lines_to_blocks([ %Line.Ruler{type: "-"} ])
    assert result == [ %Block.Ruler{type: "-"} ]
  end

  ###############
  # Block Quote #
  ###############

  test "Basic block quote" do
    result = Block.lines_to_blocks([
               %Line.BlockQuote{content: "line 1"},
               %Line.BlockQuote{content: "line 2"}
             ])

    expected = [%Block.BlockQuote{blocks: [%Block.Para{lines: ["line 1", "line 2"]}]}]
    assert result == expected
  end

  test "Block quote where continuation lines don't start >" do
    result = Block.lines_to_blocks([
               %Line.BlockQuote{content: "line 1"},
               %Line.Text{content: "line 2"}
             ])

    expected = [%Block.BlockQuote{blocks: [%Block.Para{lines: ["line 1", "line 2"]}]}]
    assert result == expected
  end

  #########
  # Lists #
  #########

  test "Basic UL" do
    result = Block.lines_to_blocks([
               %Line.UlItem{bullet: "*", content: "line 1"}
             ])
    expected = [ %Block.List{ items: [
         %Block.UlItem{blocks: [%Block.Para{lines: ["line 1"]}], spaced: true}
    ]}]
    assert result == expected
  end

  test "Multiline UL" do
    result = Block.lines_to_blocks([
               %Line.UlItem{bullet: "*", content: "line 1"},
               %Line.Text{content: "line 2"}
             ])
    expected = [ %Block.List{ items: [
         %Block.UlItem{blocks: [%Block.Para{lines: ["line 1", "line 2"]}], spaced: true}
    ]}]
    assert result == expected
  end

  test "UL containing two paras" do
    result = Block.lines_to_blocks([
               %Line.UlItem{bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Indent{content: "line 2", level: 1},
               %Line.Blank{}
             ])
    expected = [ %Block.List{ items: [
         %Block.UlItem{blocks: [%Block.Para{lines: ["line 1"]},
                                %Block.Para{lines: ["line 2"]}],
                                spaced: true}
    ]}]
    assert result == expected
  end

  test "Multiline UL followed by a blank line" do
    result = Block.lines_to_blocks([
               %Line.UlItem{bullet: "*", content: "line 1"},
               %Line.Text{content: "line 2"},
               %Line.Blank{}
             ])
    expected = [ %Block.List{ items: [
         %Block.UlItem{blocks: [%Block.Para{lines: ["line 1", "line 2"]}], spaced: true}
    ]}]
    assert result == expected
  end

  test "Two adjacent UL items, the first is not spaced" do
    result = Block.lines_to_blocks([
               %Line.UlItem{bullet: "*", content: "line 1"},
               %Line.UlItem{bullet: "*", content: "line 2"},
             ])
    expected = [ %Block.List{ items: [
       %Block.UlItem{blocks: [%Block.Para{lines: ["line 1"]}], spaced: false},
       %Block.UlItem{blocks: [%Block.Para{lines: ["line 2"]}], spaced: true},
    ]}]
    assert result == expected
  end

  test "Two UL items with a blank line between are both spaced" do
    result = Block.lines_to_blocks([
               %Line.UlItem{bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.UlItem{bullet: "*", content: "line 2"},
             ])
    expected = [ %Block.List{ items: [
       %Block.UlItem{blocks: [%Block.Para{lines: ["line 1"]}], spaced: true},
       %Block.UlItem{blocks: [%Block.Para{lines: ["line 2"]}], spaced: true},
    ]}]
    assert result == expected
  end

  test "Two UL items followed by a non-indented paragraph" do
    result = Block.lines_to_blocks([
               %Line.UlItem{bullet: "*", content: "line 1"},
               %Line.UlItem{bullet: "*", content: "line 2"},
               %Line.Blank{},
               %Line.Text{content: "para"}
             ])
    expected = [ 
       %Block.List{ items: [
         %Block.UlItem{blocks: [%Block.Para{lines: ["line 1"]}], spaced: false},
         %Block.UlItem{blocks: [%Block.Para{lines: ["line 2"]}], spaced: true},
       ]},
       %Block.Para{lines: ["para"]},
    ]
    assert result == expected
  end

  test "Code nested in list" do
    result = Block.lines_to_blocks([
               %Line.UlItem{bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Indent{level: 2, content: "code 1"},
               %Line.Indent{level: 3, content: "code 2"},
               %Line.Blank{},
               %Line.Indent{level: 1, content: "line 2"},
             ])

    expected = [ %Block.List{ items: [
       %Block.UlItem{blocks: [
               %Block.Para{lines: ["line 1"]},
               %Block.Code{language: nil, lines: ["code 1", "    code 2", ""]},
               %Block.Para{lines: ["line 2"]}], spaced: true}
    ]}]
    
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
             ])

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
             ])

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
             ])
    expected = [%Block.Code{language: "elixir", lines: ["line 1", "", "    line 2"]}]
    assert result == expected
  end

  test "fenced code ignores opposite fence" do
    result = Block.lines_to_blocks([
                  %Line.Fence{delimiter: "~~~", language: "elixir"},
                  %Line.Fence{delimiter: "```", language: "elixir", line: "``` elixir"},
                  %Line.Text{content: "line 1", line: "line 1"},
                  %Line.Fence{delimiter: "~~~"},
             ])
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
             ])

    expected = [%Block.Html{tag: "table", html: 
                 ["<table class='c'>", 
                  "line 1", 
                  "<pre>", 
                  "line 2",
                  "</pre>", 
                  "line 3"]}]   # stet—closing tag not needed

    assert result == expected
  end
end
