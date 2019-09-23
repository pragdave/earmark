defmodule TableTest do
  use ExUnit.Case, async: true

  alias Earmark.Line
  alias Earmark.Options
  alias Earmark.Block
  alias Earmark.Parser

  test "test one table line is just a paragraph" do
    result = lines_to_blocks([
                %Line.TableLine{columns: ~w{a b c}, line: "a | b | c"},
                %Line.Blank{}
             ], options())

    assert result == {[ %Block.Para{lines: ["a | b | c"], lnb: 1} ], options()}
  end

  test "test two table lines make a table" do
    result = lines_to_blocks([
                %Line.TableLine{columns: ~w{a b c}, line: "a | b | c"},
                %Line.TableLine{columns: ~w{d e f}, line: "d | e | f"},
                %Line.Blank{}
             ], options())

    expected = %Block.Table{
      rows:       [ ~w{a b c}, ~w{d e f} ],
      alignments: [ :left, :left, :left ],
      header:     nil}

    assert result == {[ expected ], options()}
  end

  test "test heading" do
    result = lines_to_blocks([
                %Line.TableLine{columns: ~w{a b c},        line: "a | b | c"},
                %Line.TableLine{columns: ~w{ --- --- ---}, line: "--|---|--"},
                %Line.TableLine{columns: ~w{d e f},        line: "d | e | f"},
                %Line.Blank{}
             ], options())

    expected = %Block.Table{
      header:     ~w{a b c},
      rows:       [ ~w{d e f} ],
      alignments: [ :left, :left, :left ]}

    assert result == {[ expected ], options()}
  end

  test "test alignment" do
    result = lines_to_blocks([
                %Line.TableLine{columns: ~w{a b c},        line: "a | b | c"},
                %Line.TableLine{columns: ~w{ --: :--: :---}, line: "--|---|--"},
                %Line.TableLine{columns: ~w{d e f},        line: "d | e | f"},
                %Line.Blank{}
             ], options())

    expected = %Block.Table{
      header:     ~w{a b c},
      rows:       [ ~w{d e f} ],
      alignments: [ :right, :center, :left ]}

    assert result == {[ expected ], options()}
  end

  test "markdown in cells" do
    result = Earmark.as_html!(["a | _b_ | `c`", " <xx>d</xx> | **e** | __f__"])
    expected = """
    <table>
    <tbody>
    <tr>
    <td style="text-align: left">a</td><td style="text-align: left"><em>b</em></td><td style="text-align: left"><code class="inline">c</code></td>
    </tr>
    <tr>
    <td style="text-align: left"><xx>d</xx></td><td style="text-align: left"><strong>e</strong></td><td style="text-align: left"><strong>f</strong></td>
    </tr>
    </tbody>
    </table>
    """
    assert result == expected
  end

  defp options do
    %Options{file: "file name"}
  end

  defp lines_to_blocks(lines, options) do
    {blks, _links, opts} = Parser.parse_lines(lines, options)
    {blks, opts}
  end
end

# SPDX-License-Identifier: Apache-2.0
