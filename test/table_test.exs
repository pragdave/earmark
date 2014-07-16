defmodule TableTest do
  use ExUnit.Case

  alias Earmark.Line
  alias Earmark.Block

  test "test one table line is just a paragraph" do
    result = Block.lines_to_blocks([
                %Line.TableLine{columns: ~w{a b c}, line: "a | b | c"}, 
                %Line.Blank{}
             ])

    assert result == [ %Block.Para{lines: ["a | b | c"]} ]
  end

  test "test two table lines make a table" do
    result = Block.lines_to_blocks([
                %Line.TableLine{columns: ~w{a b c}, line: "a | b | c"}, 
                %Line.TableLine{columns: ~w{d e f}, line: "d | e | f"}, 
                %Line.Blank{}
             ])

    expected = %Block.Table{
      rows:       [ ~w{a b c}, ~w{d e f} ], 
      alignments: [ :left, :left, :left ],
      header:     nil}

    assert result == [ expected ]
  end

  test "test heading" do
    result = Block.lines_to_blocks([
                %Line.TableLine{columns: ~w{a b c},        line: "a | b | c"}, 
                %Line.TableLine{columns: ~w{ --- --- ---}, line: "--|---|--"}, 
                %Line.TableLine{columns: ~w{d e f},        line: "d | e | f"}, 
                %Line.Blank{}
             ])

    expected = %Block.Table{
      header:     ~w{a b c}, 
      rows:       [ ~w{d e f} ], 
      alignments: [ :left, :left, :left ]}

    assert result == [ expected ]
  end

  test "test alignment" do
    result = Block.lines_to_blocks([
                %Line.TableLine{columns: ~w{a b c},        line: "a | b | c"}, 
                %Line.TableLine{columns: ~w{ --: :--: :---}, line: "--|---|--"}, 
                %Line.TableLine{columns: ~w{d e f},        line: "d | e | f"}, 
                %Line.Blank{}
             ])

    expected = %Block.Table{
      header:     ~w{a b c}, 
      rows:       [ ~w{d e f} ], 
      alignments: [ :right, :center, :left ]}

    assert result == [ expected ]
  end


  
  test "Simple table render" do
    result = Earmark.to_html(["a | b | c", "d | e | f"])
    expected = """
    <table>
    <colgroup>
    <col align="left">
    <col align="left">
    <col align="left">

    </colgroup>
    <tr>
    <td>a</td><td>b</td><td>c</td>
    </tr>
    <tr>
    <td>d</td><td>e</td><td>f</td>
    </tr>
    </table>
    """
    assert result == expected
  end

  test "Table with heading and alignment" do
    result = Earmark.to_html(["a | b | c", ":-- | :--: |--:", "d | e | f"])
    expected = """
    <table>
    <colgroup>
    <col align="left">
    <col align="center">
    <col align="right">

    </colgroup>
    <thead>
    <tr>
    <th>a</th><th>b</th><th>c</th>
    </tr>
    </thead>
    <tr>
    <td>d</td><td>e</td><td>f</td>
    </tr>
    </table>
    """
    assert result == expected
  end

  test "markdown in cells" do
    result = Earmark.to_html(["a | _b_ | `c`", " <xx>d</xx> | **e** | __f__"])
    expected = """
    <table>
    <colgroup>
    <col align="left">
    <col align="left">
    <col align="left">

    </colgroup>
    <tr>
    <td>a</td><td><em>b</em></td><td><code class="inline">c</code></td>
    </tr>
    <tr>
    <td><xx>d</xx></td><td><strong>e</strong></td><td><strong>f</strong></td>
    </tr>
    </table>
    """
    assert result == expected
  end

end