defmodule Regressions.I066ErrorContextTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "Issue https://github.com/pragdave/earmark/issues/66 1" do
    assert capture_io( :stderr, fn->
      Earmark.as_html! ~s(`Hello\nWorld), %Earmark.Options{file: "fn"}
    end) == "fn:1: warning: Closing unclosed backquotes ` at end of input\n"
  end

  test "Issue https://github.com/pragdave/earmark/issues/66 2" do
    assert capture_io( :stderr, fn->
      Earmark.as_html! ~s(And\n`Hello\nWorld)
    end) == "<no file>:2: warning: Closing unclosed backquotes ` at end of input\n"
  end

  test "Issue https://github.com/pragdave/earmark/issues/66 3" do
    assert capture_io( :stderr, fn->
      Earmark.as_html! ~s(* And\n* `Hello\n* World)
    end) == "<no file>:2: warning: Closing unclosed backquotes ` at end of input\n"
  end

  test "Issue https://github.com/pragdave/earmark/issues/66 4" do
    assert capture_io( :stderr, fn->
      Earmark.as_html! ~s(* And\n* `Hello\n* World), %Earmark.Options{line: 42}
    end) == "<no file>:43: warning: Closing unclosed backquotes ` at end of input\n"
  end
end
