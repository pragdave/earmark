defmodule Regressions.I078EscapedEscapesEscapeBacktix do
  use ExUnit.Case
  import ExUnit.CaptureIO

  defp open_file(filename) do
    case File.open(filename, [:utf8]) do
      {:ok, device} -> device 
      {:error, reason} -> IO.puts(:stderr, "Unable to open file: #{filename}, #{reason}")
    end
  end

  defp html_from_file(filename) do 
    IO.stream( open_file(filename), :line)
    |> Enum.to_list()
    |> Earmark.to_html()
  end

  test "Issue https://github.com/pragdave/earmark/issues/78 broken markdown" do 

    # Broken code in line 24
    assert capture_io( :stderr, fn->
      html_from_file("test/fixtures/i077_broken.md")
    end) == "<no file>:42: warning: Closing unclosed backquotes ` at end of input\n"
    # Yes this is correct unless we forbid multiline inline code blocks the error
    # cannot be detected earlier
  end


  test "Issue https://github.com/pragdave/earmark/issues/78 fixed markdown" do 
    # Fixed code in line 24
    assert capture_io( :stderr, fn->
      html_from_file("test/fixtures/i077_fixed.md")
    end) == ""
  end
end
