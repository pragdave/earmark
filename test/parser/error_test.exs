defmodule Parser.ErrorTest do 
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Earmark.Options

  test "Unexpected line" do 
    assert capture_io( :stderr, fn->
      Earmark.to_html "A\nB\n="
    end) == "<no file>:3: warning: Unexpected line =\n"
  end

  test "Closing Backtick" do 
    assert capture_io( :stderr, fn->
      Earmark.to_html "A\n`B\n"
    end) == "<no file>:2: warning: close pending \"`\", multiline inline code blocks are deprecated\n"
  end

  test "Closing Backtick chained" do
    messages = Enum.join( 
    ["<no file>:2: warning: close pending \"`\", multiline inline code blocks are deprecated\n",
     "<no file>:3: warning: close pending \"``\", multiline inline code blocks are deprecated\n"])

    assert capture_io( :stderr, fn ->
      Earmark.to_html "one\n`\n`` ` ```"
    end) == messages
  end

  test "Closing Backtick in list" do
    assert capture_io( :stderr, fn ->
      Earmark.to_html "* one\n* two\n* `three\nfour", %Options{filename: "list.md"}
    end) == "list.md:3: warning: close pending \"`\", multiline inline code blocks are deprecated\n"
  end

  test "Closing Backtick before list" do
    messages = Enum.join( 
    ["<no file>:1: warning: close pending \"`\", multiline inline code blocks are deprecated\n",
     "<no file>:2: warning: close pending \"`\", multiline inline code blocks are deprecated\n"])
    assert capture_io( :stderr, fn ->
      Earmark.to_html "one`\n* two ` ``"
    end) == messages
  end

  test "Failed to find closing tag" do 
    assert capture_io( :stderr, fn ->
      Earmark.to_html "one\ntwo\n<three>\nfour", %Options{filename: "input_file.md"}
    end) == "input_file.md:3: warning: Failed to find closing <three>\n"
  end

  test "Opening Backtick inside list" do
    assert capture_io( :stderr, fn ->
      Earmark.to_html "* `"
    end) == "<no file>:1: warning: close pending \"`\", multiline inline code blocks are deprecated\n"
  end

  test "Closing Backtick after list" do
    messages = Enum.join(  
    ["<no file>:2: warning: close pending \"`\", multiline inline code blocks are deprecated\n",
     "<no file>:4: warning: close pending \"`\", multiline inline code blocks are deprecated\n"])
    assert capture_io( :stderr, fn ->
      Earmark.to_html "\n* `\n\nHello `"
    end) == messages
  end
end
