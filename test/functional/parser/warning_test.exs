defmodule Parser.WarningTest do
  use ExUnit.Case

  alias Earmark.Options

  test "Unexpected line" do
    warnings = messages_from_parse( "A\nB\n=")
    assert warnings == [{ :warning, 3, "Unexpected line ="}]
  end

  test "Unexpected line, with lnb" do
    warnings = messages_from_parse( "A\nB\n=", %Options{line:  42})
    assert warnings == [{ :warning, 44, "Unexpected line ="}]
  end

  test "Closing Backtick" do
    warnings = messages_from_parse( "A\n`B\n")
    assert warnings == [{ :warning, 2, "Closing unclosed backquotes ` at end of input"}]
  end

  test "Closing Backtick, with lnb" do
    warnings = messages_from_parse( "A\n`B\n", %Options{line:  42})
    assert warnings == [{ :warning, 43, "Closing unclosed backquotes ` at end of input"}]
  end

  test "Closing Backtick chained" do
    warnings = messages_from_parse( "one\n`\n`` ` ```")
    assert warnings == [{ :warning, 3, "Closing unclosed backquotes ``` at end of input"}]
  end

  test "Closing Backtick chained, with lnb" do
    warnings = messages_from_parse( "one\n`\n`` ` ```", %Options{line:  42})
    assert warnings == [{ :warning, 44, "Closing unclosed backquotes ``` at end of input"}]
  end

  test "Closing Backtick in list" do
    warnings = messages_from_parse( "* one\n* two\n* `three\nfour", %Options{file: "list.md"})
    assert warnings == [{:warning, 3, "Closing unclosed backquotes ` at end of input"}]
  end

  test "Closing Backtick in list, with lnb" do
    warnings = messages_from_parse( "* one\n* two\n* `three\nfour", %Options{file: "list.md", line:  24})
    assert warnings == [{ :warning, 26, "Closing unclosed backquotes ` at end of input"}]
  end

  test "Closing Backtick before list" do
    warnings = messages_from_parse( "one`\n* two ` ``")
    assert warnings == [{ :warning, 2, "Closing unclosed backquotes `` at end of input"}]
  end

  test "Closing Backtick before list, with lnb" do
    warnings = messages_from_parse( "one`\n* two ` ``", %Options{line:  42})
    assert warnings == [{ :warning, 43, "Closing unclosed backquotes `` at end of input"}]
  end

  test "Failed to find closing tag" do
    warnings = messages_from_parse( "one\ntwo\n<three>\nfour", %Options{file: "input_file.md"})
    assert warnings == [{ :warning, 3, "Failed to find closing <three>"}]
  end

  test "Failed to find closing tag, with lnb" do
    warnings = messages_from_parse( "one\ntwo\n<three>\nfour", %Options{file: "input_file.md", line:  23})
    assert warnings == [{ :warning, 25, "Failed to find closing <three>"}]
  end

  test "Opening Backtick inside list" do
    warnings = messages_from_parse( "* `")
    assert warnings == [{ :warning, 1, "Closing unclosed backquotes ` at end of input"}]
  end

  test "Opening Backtick inside list, with lnb" do
    warnings = messages_from_parse( "* `", %Options{line:  42})
    assert warnings == [{ :warning, 42, "Closing unclosed backquotes ` at end of input"}]
  end

  test "Closing Backtick after list" do
    warnings = messages_from_parse( "\n* `\n\nHello `")
    assert warnings == []
  end

  defp messages_from_parse(str, options \\ %Earmark.Options{}) do
    with {_, context} <- Earmark.parse(str, options), do: context.options.messages
  end
end
