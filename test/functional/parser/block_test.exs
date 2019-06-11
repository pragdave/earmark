defmodule BlockTest do
  use ExUnit.Case

  alias Earmark.Line
  alias Earmark.Block
  alias Earmark.Parser

  ############
  # Headings #
  ############

  test "Setext Heading" do
    result = lines_to_blocks([
                %Line.Blank{},
                %Line.Text{content: "Heading"},
                %Line.SetextUnderlineHeading{level: 1}
                # %Line.Blank{}
             ], options())

    assert result == {[ %Block.Heading{content: "Heading", level: 1} ], options() }
  end

  test "Regular heading" do
    result = lines_to_blocks([ %Line.Heading{content: "Heading", level: 2} ], options())
    assert result == {[ %Block.Heading{content: "Heading", level: 2} ], options()}
  end

  ##########
  # Rulers #
  ##########

  test "Ruler" do
    result = lines_to_blocks([ %Line.Ruler{type: "-"} ], options())
    assert result == {[ %Block.Ruler{type: "-"} ], options()}
  end

  ###############
  # Block Quote #
  ###############

  test "Basic block quote" do
    result = lines_to_blocks([
               %Line.BlockQuote{content: "line 1", lnb: 1},
               %Line.BlockQuote{content: "line 2", lnb: 2}
             ], options())

    expected = {[%Block.BlockQuote{lnb: 1, blocks: [%Block.Para{lines: ["line 1", "line 2"], lnb: 1}]}], options()}
    assert result == expected
  end

  test "Block quote where continuation lines don't start >" do
    result = lines_to_blocks([
               %Line.BlockQuote{content: "line 1", lnb: 1},
               %Line.Text{content: "line 2", lnb: 2}
             ], options())

    expected = {[%Block.BlockQuote{lnb: 1, blocks: [%Block.Para{lines: ["line 1", "line 2"], lnb: 1}]}], options()}
    assert result == expected
  end


  ########
  # Code #
  ########

  test "simple indented code" do
    result = lines_to_blocks([
                  %Line.Indent{level: 1, content: "line 1"},
                  %Line.Indent{level: 1, content: " line 2"},
                  %Line.Blank{},
                  %Line.Indent{level: 1, content: " line 3"},
                  %Line.Indent{level: 1, content: "line 4"}
             ], options())

    expected = {[%Block.Code{language: nil,
                            lines: ["line 1", " line 2", "", " line 3", "line 4"]}], options()}
    assert result == expected
  end

  test "indented code at multiple levels" do
    result = lines_to_blocks([
                  %Line.Indent{level: 1, content: "line 1"},
                  %Line.Indent{level: 1, content: "  line 2"},
                  %Line.Indent{level: 2, content: "line 3"},
                  %Line.Indent{level: 2, content: "  line 4"}
             ], options())

    expected = {[%Block.Code{language: nil,
                            lines: ["line 1", "  line 2", "    line 3", "      line 4"]}], options()}
    assert result == expected
  end

  test "fenced code with ~~~" do
    result = lines_to_blocks([
                  %Line.Fence{delimiter: "~~~", language: "elixir"},
                  %Line.Text{content: "line 1", line: "line 1"},
                  %Line.Blank{line: ""},
                  %Line.Indent{level: 1, content: "line 2", line: "    line 2"},
                  %Line.Fence{delimiter: "~~~"},
             ], options())
    expected = {[%Block.Code{language: "elixir", lines: ["line 1", "", "    line 2"]}], options()}
    assert result == expected
  end

  test "fenced code ignores opposite fence" do
    result = lines_to_blocks([
                  %Line.Fence{delimiter: "~~~", language: "elixir"},
                  %Line.Fence{delimiter: "```", language: "elixir", line: "``` elixir"},
                  %Line.Text{content: "line 1", line: "line 1"},
                  %Line.Fence{delimiter: "~~~"},
             ], options())
    expected = {[%Block.Code{language: "elixir", lines: ["``` elixir", "line 1"]}], options()}
    assert result == expected
  end

  ##############
  # HTML Block #
  ##############

  test "HTML Block" do
    result = lines_to_blocks([
                  %Line.HtmlOpenTag{tag: "table", line: "<table class='c'>"},
                  %Line.Text{line: "line 1"},
                  %Line.HtmlOpenTag{tag: "pre", line: "<pre>"},
                  %Line.Ruler{line: "line 2"},
                  %Line.HtmlCloseTag{tag: "pre", line: "</pre>"},
                  %Line.Text{line: "line 3"},
                  %Line.HtmlCloseTag{tag: "table", line: "</table>"},
             ], options())

    expected = {[%Block.Html{tag: "table", html:
                 ["<table class='c'>",
                  "line 1",
                  "<pre>",
                  "line 2",
                  "</pre>",
                  "line 3",
                  "</table>"]}], options()}

    assert result == expected
  end

  test "Nested HTML Block" do
    result = lines_to_blocks([
                  %Line.HtmlOpenTag{tag: "table", line: "<table class='c'>"},
                  %Line.Text{line: "line 1"},
                  %Line.HtmlOpenTag{tag: "table", line: "<table>"},
                  %Line.Ruler{line: "line 2"},
                  %Line.HtmlCloseTag{tag: "table", line: "</table>"},
                  %Line.Text{line: "line 3"},
                  %Line.HtmlCloseTag{tag: "table", line: "</table>"},
             ], options())

    expected = {[%Block.Html{tag: "table", html:
                 ["<table class='c'>",
                  "line 1",
                  "<table>",
                  "line 2",
                  "</table>",
                  "line 3",
                  "</table>"]}], options()}

    assert result == expected
  end


  test "HTML comment on one line" do
    result = lines_to_blocks([
                  %Line.HtmlComment{line: "<!-- xx -->", complete: true}
             ], options())
    expected = {[ %Block.HtmlOther{html: [ "<!-- xx -->" ]}], options()}

    assert result == expected
  end

  test "HTML comment on multiple lines" do
    result = lines_to_blocks([
                  %Line.HtmlComment{line: "<!-- ", complete: false},
                  %Line.Indent{level: 2, line: "xxx"},
                  %Line.Text{line: "-->"}
             ], options())
    expected = {[ %Block.HtmlOther{html: ["<!-- ", "xxx", "-->"]}], options()}

    assert result == expected
  end

  ##################
  # ID definitions #
  ##################

  test "Basic ID definition" do
    result = lines_to_blocks([
                  %Line.IdDef{id: "id1", url: "url1", title: "title1"}
             ], options())

    assert result == {[%Block.IdDef{id: "id1", title: "title1", url: "url1"}], options()}
  end

  test "ID definition with title on next line" do
    result = lines_to_blocks([
                  %Line.IdDef{id: "id1", url: "url1"},
                  %Line.Text{content: "  (title1)"}
             ], options())

    assert result == {[%Block.IdDef{id: "id1", title: "title1", url: "url1"}], options()}
  end

  test "ID definition with no title and no title on next line" do
    result = lines_to_blocks([
                  %Line.IdDef{id: "id1", url: "url1"},
                  %Line.Text{content: "  not title1", line: "  not title1"}
             ], options())

    assert result == {[
        %Block.IdDef{id: "id1", title: nil, url: "url1"},
        %Block.Para{lines: [ "  not title1" ]}
    ], options()}
  end

  ################################################
  # IALs get associated with the preceding block #
  ################################################

  test "IAL gets associated with previous block" do
    result = lines_to_blocks([
                  %Line.Text{line: "line", content: "line"},
                  %Line.Ial{attrs: ".a1 .a2"},
                  %Line.Text{content: "another", line: "another"}
             ], options())

    assert result == {[
        %Block.Para{lines: [ "line" ], attrs: %{"class" => ~w[a2 a1]}},
        %Block.Para{lines: [ "another" ], attrs: nil}
    ], options()}
  end

  ######################################################
  # Test that we correctly accumulate the definitions  #
  ######################################################

  test "Accumulate basic ID definition" do
    {blocks, refs, _ } = Parser.parse_lines([
                  %Line.IdDef{id: "id1", url: "url1", title: "title1"}
             ], options())

    defn = %Block.IdDef{id: "id1", title: "title1", url: "url1"}
    assert blocks == [defn]
    assert refs == ([{ "id1", defn}] |> Enum.into(Map.new))
  end

  test "ID definition nested in list" do
    { blocks, refs, _ } = Parser.parse_lines([
               %Line.ListItem{type: :ul, bullet: "*", content: "line 1"},
               %Line.Blank{},
               %Line.Indent{level: 1, content: "[id1]: url1  (title1)"},
             ], options())

    defn = %Block.IdDef{id: "id1", title: "title1", url: "url1", lnb: 2}

    expected = [ %Block.List{ type: :ul, blocks: [
       %Block.ListItem{type: :ul, spaced: false, bullet: "*", blocks: [
               %Block.Para{lines: ["line 1"]},
               defn
    ]}]}]

    assert blocks == expected
    assert refs == ([{ "id1", defn}] |> Enum.into(Map.new))
  end

  defp options do
    %Earmark.Options{file: "some filename"}
  end

  defp lines_to_blocks(lines, options) do
    {blks, _links, opts} = Parser.parse_lines(lines, options)
    {blks, opts}
  end
end

# SPDX-License-Identifier: Apache-2.0
