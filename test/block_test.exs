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
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"}
             ])
    expected = [ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false}
    ]}]
    assert result == expected
  end

  test "Multiline UL" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Text{content: "line 2"}
             ])
    expected = [ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{type: :ul, blocks: [
                %Block.Para{lines: ["line 1", "line 2"]}], spaced: false}
    ]}]
    assert result == expected
  end

  test "UL containing two paras" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Indent{content: "line 2", level: 1},
               %Line.Blank{}
             ])
    expected = [ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{blocks: [%Block.Para{lines: ["line 1"]},
                                %Block.Para{lines: ["line 2"]}],
                                spaced: false, type: :ul}
    ]}]
    assert result == expected
  end

  test "UL containing two paras where the second is only indented 2 spaces" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Text{content: "  line 2", line: "  line 2"},
               %Line.Blank{}
             ])
    expected = [ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{blocks: [%Block.Para{lines: ["line 1"]},
                                %Block.Para{lines: ["  line 2"]}],
                                spaced: false, type: :ul}
    ]}]
    assert result == expected
  end

  test "Multiline UL followed by a blank line" do
    result = Block.lines_to_blocks([
               %Line.ListItem{bullet: "*", content: "line 1"},
               %Line.Text{content: "line 2"},
               %Line.Blank{}
             ])
    expected = [ %Block.List{ type: :ul, blocks: [
         %Block.ListItem{type: :ul, blocks: [
                 %Block.Para{lines: ["line 1", "line 2"]}], spaced: false}
    ]}]
    assert result == expected
  end

  test "Two adjacent UL items, the first is not spaced" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.ListItem{type: :ul, bullet: "*", content: "line 2"},
             ])
    expected = [ %Block.List{ type: :ul, blocks: [
       %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false},
       %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 2"]}], spaced: false},
    ]}]
    assert result == expected
  end

  test "Two UL items with a blank line between are both spaced" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.ListItem{type: :ul, bullet: "*", content: "line 2"},
             ])
    expected = [ %Block.List{ type: :ul, blocks: [
       %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: true},
       %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 2"]}], spaced: false},
    ]}]
    assert result == expected
  end

  test "Two UL items followed by a non-indented paragraph" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.ListItem{type: :ul, bullet: "*", content: "line 2"},
               %Line.Blank{},
               %Line.Text{content: "para", line: "para"}
             ])
    expected = [ 
       %Block.List{ type: :ul, blocks: [
         %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false},
         %Block.ListItem{type: :ul, blocks: [%Block.Para{lines: ["line 2"]}], spaced: false},
       ]},
       %Block.Para{lines: ["para"]},
    ]
    assert result == expected
  end

  test "Code nested in list" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Indent{level: 2, content: "code 1"},
               %Line.Indent{level: 3, content: "code 2"},
               %Line.Blank{},
               %Line.Indent{level: 1, content: "line 2"},
             ])

    expected = [ %Block.List{ type: :ul, blocks: [
       %Block.ListItem{type: :ul, blocks: [
               %Block.Para{lines: ["line 1"]},
               %Block.Code{language: nil, lines: ["code 1", "    code 2", ""]},
               %Block.Para{lines: ["line 2"]}], spaced: false}
    ]}]
    
    assert result == expected
  end

  # OLs are handled by the same code as ULs, so to save time, we really just
  # need a single smoke test. If this changes in future, we'll need to 
  # relook at this

  test "Basic OL" do
    result = Block.lines_to_blocks([
               %Line.ListItem{type: :ol, bullet: "1.", content: "line 1"}
             ])
    expected = [ %Block.List{ type: :ol, blocks: [
         %Block.ListItem{type: :ol, blocks: [%Block.Para{lines: ["line 1"]}], spaced: false}
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
             ])

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
             ])
    expected = [ %Block.HtmlOther{html: [ "<!-- xx -->" ]}]

    assert result == expected
  end

  test "HTML comment on multiple lines" do
    result = Block.lines_to_blocks([
                  %Line.HtmlComment{line: "<!-- ", complete: false},
                  %Line.Indent{level: 2, line: "xxx"},
                  %Line.Text{line: "-->"}
             ])
    expected = [ %Block.HtmlOther{html: ["<!-- ", "xxx", "-->"]}]

    assert result == expected
  end

  ##################
  # ID definitions #
  ##################

  test "Basic ID definition" do
    result = Block.lines_to_blocks([
                  %Line.IdDef{id: "id1", url: "url1", title: "title1"}
             ])

    assert result == [%Block.IdDef{id: "id1", title: "title1", url: "url1"}]
  end

  test "ID definition with title on next line" do
    result = Block.lines_to_blocks([
                  %Line.IdDef{id: "id1", url: "url1"},
                  %Line.Text{content: "  (title1)"}
             ])

    assert result == [%Block.IdDef{id: "id1", title: "title1", url: "url1"}]
  end

  test "ID definition with no title and no title on next line" do
    result = Block.lines_to_blocks([
                  %Line.IdDef{id: "id1", url: "url1"},
                  %Line.Text{content: "  not title1", line: "  not title1"}
             ])

    assert result == [
        %Block.IdDef{id: "id1", title: nil, url: "url1"},
        %Block.Para{lines: [ "  not title1" ]} 
    ]
  end

  ######################################################
  # Test that we correctly accumulate the definitions  #
  ######################################################

  test "Accumulate basic ID definition" do
    {blocks, refs } = Block.parse([
                  %Line.IdDef{id: "id1", url: "url1", title: "title1"}
             ])

    defn = %Block.IdDef{id: "id1", title: "title1", url: "url1"}
    assert blocks == [defn]
    assert refs == ([{ "id1", defn}] |> Enum.into(HashDict.new))
  end

  test "ID definition nested in list" do
    { blocks, refs } = Block.parse([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Indent{level: 1, content: "[id1]: url1  (title1)"},
             ])

    defn = %Block.IdDef{id: "id1", title: "title1", url: "url1"}

    expected = [ %Block.List{ type: :ul, blocks: [
       %Block.ListItem{type: :ul, spaced: false, blocks: [
               %Block.Para{lines: ["line 1"]},
               defn
    ]}]}]
    
    assert blocks == expected
    assert refs == ([{ "id1", defn}] |> Enum.into(HashDict.new))
  end

end
