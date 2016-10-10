defmodule Parser.ErrorTest do 
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Earmark.Options

  test "Unexpected line" do 
    assert capture_io( :stderr, fn->
      Earmark.parse "A\nB\n="
    end) == "<no file>:3: warning: Unexpected line =\n"
  end

  test "Unexpected line, with lnb" do 
    assert capture_io( :stderr, fn->
      Earmark.parse "A\nB\n=", %Options{line: 42}
    end) == "<no file>:44: warning: Unexpected line =\n"
  end

  test "Closing Backtick" do 
    assert capture_io( :stderr, fn->
      Earmark.parse "A\n`B\n"
    end) == "<no file>:2: warning: Closing unclosed backquotes ` at end of input\n"
  end

  test "Closing Backtick, with lnb" do 
    assert capture_io( :stderr, fn->
      Earmark.parse "A\n`B\n", %Options{line: 42}
    end) == "<no file>:43: warning: Closing unclosed backquotes ` at end of input\n"
  end

  test "Closing Backtick chained" do
    assert capture_io( :stderr, fn ->
      Earmark.parse "one\n`\n`` ` ```"
    end) == "<no file>:3: warning: Closing unclosed backquotes ``` at end of input\n"
  end

  test "Closing Backtick chained, with lnb" do
    assert capture_io( :stderr, fn ->
      Earmark.parse "one\n`\n`` ` ```", %Options{line: 42}
    end) == "<no file>:44: warning: Closing unclosed backquotes ``` at end of input\n"
  end

  test "Closing Backtick in list" do
    assert capture_io( :stderr, fn ->
      Earmark.parse "* one\n* two\n* `three\nfour", %Options{file: "list.md"}
    end) == "list.md:3: warning: Closing unclosed backquotes ` at end of input\n"
  end

  test "Closing Backtick in list, with lnb" do
    assert capture_io( :stderr, fn ->
      Earmark.parse "* one\n* two\n* `three\nfour", %Options{file: "list.md", line: 24}
    end) == "list.md:26: warning: Closing unclosed backquotes ` at end of input\n"
  end

  test "Closing Backtick before list" do
    assert capture_io( :stderr, fn ->
      Earmark.parse "one`\n* two ` ``"
    end) == "<no file>:2: warning: Closing unclosed backquotes `` at end of input\n"
  end

  test "Closing Backtick before list, with lnb" do
    assert capture_io( :stderr, fn ->
      Earmark.parse "one`\n* two ` ``", %Options{line: 42}
    end) == "<no file>:43: warning: Closing unclosed backquotes `` at end of input\n"
  end

  test "Failed to find closing tag" do 
    assert capture_io( :stderr, fn ->
      Earmark.parse "one\ntwo\n<three>\nfour", %Options{file: "input_file.md"}
    end) == "input_file.md:3: warning: Failed to find closing <three>\n"
  end

  test "Failed to find closing tag, with lnb" do 
    assert capture_io( :stderr, fn ->
      Earmark.parse "one\ntwo\n<three>\nfour", %Options{file: "input_file.md", line: 23}
    end) == "input_file.md:25: warning: Failed to find closing <three>\n"
  end

  test "Opening Backtick inside list" do
    assert capture_io( :stderr, fn ->
      Earmark.parse "* `"
    end) == "<no file>:1: warning: Closing unclosed backquotes ` at end of input\n"
  end

  test "Opening Backtick inside list, with lnb" do
    assert capture_io( :stderr, fn ->
      Earmark.parse "* `", %Options{line: 42}
    end) == "<no file>:42: warning: Closing unclosed backquotes ` at end of input\n"
  end

  test "Closing Backtick after list" do
    assert capture_io( :stderr, fn ->
      Earmark.parse "\n* `\n\nHello `"
    end) == ""
  end
end
