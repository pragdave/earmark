defmodule Parser.WarningTest do
  use ExUnit.Case

  alias Earmark.Options

  test "Unexpected line" do
    {_,_,warnings,_} = Earmark.parse( "A\nB\n=")
    assert warnings == ["<no file>:3: warning: Unexpected line =" ]
  end

  test "Unexpected line, with lnb" do
    {_,_,warnings,_} = Earmark.parse( "A\nB\n=", %Options{line: 42})
    assert warnings == ["<no file>:44: warning: Unexpected line =" ]
  end

  test "Closing Backtick" do
    {_,_,warnings,_} = Earmark.parse( "A\n`B\n")
    assert warnings == ["<no file>:2: warning: Closing unclosed backquotes ` at end of input" ]
  end

  test "Closing Backtick, with lnb" do
    {_,_,warnings,_} = Earmark.parse( "A\n`B\n", %Options{line: 42})
    assert warnings == ["<no file>:43: warning: Closing unclosed backquotes ` at end of input" ]
  end

  test "Closing Backtick chained" do
    {_,_,warnings,_} = Earmark.parse( "one\n`\n`` ` ```")
    assert warnings == ["<no file>:3: warning: Closing unclosed backquotes ``` at end of input" ]
  end

  test "Closing Backtick chained, with lnb" do
    {_,_,warnings,_} = Earmark.parse( "one\n`\n`` ` ```", %Options{line: 42})
    assert warnings == ["<no file>:44: warning: Closing unclosed backquotes ``` at end of input" ]
  end

  test "Closing Backtick in list" do
    {_,_,warnings,_} = Earmark.parse( "* one\n* two\n* `three\nfour", %Options{file: "list.md"})
    assert warnings == ["list.md:3: warning: Closing unclosed backquotes ` at end of input" ]
  end

  test "Closing Backtick in list, with lnb" do
    {_,_,warnings,_} = Earmark.parse( "* one\n* two\n* `three\nfour", %Options{file: "list.md", line: 24})
    assert warnings == ["list.md:26: warning: Closing unclosed backquotes ` at end of input" ]
  end

  test "Closing Backtick before list" do
    {_,_,warnings,_} = Earmark.parse( "one`\n* two ` ``")
    assert warnings == ["<no file>:2: warning: Closing unclosed backquotes `` at end of input" ]
  end

  test "Closing Backtick before list, with lnb" do
    {_,_,warnings,_} = Earmark.parse( "one`\n* two ` ``", %Options{line: 42})
    assert warnings == ["<no file>:43: warning: Closing unclosed backquotes `` at end of input" ]
  end

  test "Failed to find closing tag" do
    {_,_,warnings,_} = Earmark.parse( "one\ntwo\n<three>\nfour", %Options{file: "input_file.md"})
    assert warnings == ["input_file.md:3: warning: Failed to find closing <three>" ]
  end

  test "Failed to find closing tag, with lnb" do
    {_,_,warnings,_} = Earmark.parse( "one\ntwo\n<three>\nfour", %Options{file: "input_file.md", line: 23})
    assert warnings == ["input_file.md:25: warning: Failed to find closing <three>" ]
  end

  test "Opening Backtick inside list" do
    {_,_,warnings,_} = Earmark.parse( "* `")
    assert warnings == ["<no file>:1: warning: Closing unclosed backquotes ` at end of input" ]
  end

  test "Opening Backtick inside list, with lnb" do
    {_,_,warnings,_} = Earmark.parse( "* `", %Options{line: 42})
    assert warnings == ["<no file>:42: warning: Closing unclosed backquotes ` at end of input" ]
  end

  test "Closing Backtick after list" do
    {_,_,warnings,_} = Earmark.parse( "\n* `\n\nHello `")
    assert warnings == []
  end
end
