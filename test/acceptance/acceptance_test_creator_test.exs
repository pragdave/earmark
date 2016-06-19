defmodule AcceptanceTestCreatorTest do
  use ExUnit.Case

  alias Support.AcceptanceTestStruct
  import Test.Support.SilenceIo, only: [with_silent_io: 2]

  {:ok, test_case_data } =
  Path.join([__DIR__,"../assets/tests.json"])
  |> File.stream!( [], :line )
  |> Enum.reject( &(String.match?(&1, ~r{^\s*#})) )
  |> Enum.join( "\n" )
  |> Poison.decode( as: [%AcceptanceTestStruct{}] )


  for acceptance_test <- test_case_data do
    @tag :acceptance 
    @tag :"example_#{acceptance_test.example}"
    test "Acceptance Tests -- Section #{acceptance_test.section} (#{acceptance_test.example})\n---\n#{acceptance_test.markdown}\n---\n" do

      result = with_silent_io(:stderr, fn ->
        Earmark.to_html( unquote(acceptance_test.markdown), %Earmark.Options{smartypants: false} )
      end)
      assert result == unquote(acceptance_test.html)
    end
  end

end
