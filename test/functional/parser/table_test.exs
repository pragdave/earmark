defmodule TableTest do
  use ExUnit.Case

  alias Earmark.Line
  alias Earmark.Options
  alias Earmark.Block

  test "test one table line is just a paragraph" do
    result = Block.lines_to_blocks([
                %Line.TableLine{columns: ~w{a b c}, line: "a | b | c"},
                %Line.Blank{}
             ], options())

    assert result == {[ %Block.Para{lines: ["a | b | c"], lnb: 1} ], options()}
  end

  test "test two table lines make a table" do
    result = Block.lines_to_blocks([
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
    result = Block.lines_to_blocks([
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
    result = Block.lines_to_blocks([
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



  test "Simple table render" do
    result = Earmark.as_html!(["a | b | c", "d | e | f"])
    expected = """
    <table>
    <colgroup>
    <col>
    <col>
    <col>
    </colgroup>
    <tr>
    <td style="text-align: left">a</td><td style="text-align: left">b</td><td style="text-align: left">c</td>
    </tr>
    <tr>
    <td style="text-align: left">d</td><td style="text-align: left">e</td><td style="text-align: left">f</td>
    </tr>
    </table>
    """
    assert result == expected
  end

  test "Table with heading and alignment" do
    result = Earmark.as_html!(["a | b | c", ":-- | :--: |--:", "d | e | f"])
    expected = """
    <table>
    <colgroup>
    <col>
    <col>
    <col>
    </colgroup>
    <thead>
    <tr>
    <th style="text-align: left">a</th><th style="text-align: center">b</th><th style="text-align: right">c</th>
    </tr>
    </thead>
    <tr>
    <td style="text-align: left">d</td><td style="text-align: center">e</td><td style="text-align: right">f</td>
    </tr>
    </table>
    """
    assert result == expected
  end

  test "markdown in cells" do
    result = Earmark.as_html!(["a | _b_ | `c`", " <xx>d</xx> | **e** | __f__"])
    expected = """
    <table>
    <colgroup>
    <col>
    <col>
    <col>
    </colgroup>
    <tr>
    <td style="text-align: left">a</td><td style="text-align: left"><em>b</em></td><td style="text-align: left"><code class="inline">c</code></td>
    </tr>
    <tr>
    <td style="text-align: left"><xx>d</xx></td><td style="text-align: left"><strong>e</strong></td><td style="text-align: left"><strong>f</strong></td>
    </tr>
    </table>
    """
    assert result == expected
  end

  defp options do
    %Options{file: "file name"}
  end

end
