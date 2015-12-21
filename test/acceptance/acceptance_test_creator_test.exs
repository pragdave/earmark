defmodule AcceptanceTestCreatorTest do
  use ExUnit.Case

  alias Support.AcceptanceTestStruct

  {:ok, test_case_data } =
  Path.join([__DIR__,"../assets/tests.json"])
  |> File.stream!( [], :line )
  |> Enum.reject( &(String.match?(&1, ~r{^\s*#})) )
  |> Enum.join( "\n" )
  |> Poison.decode( as: [AcceptanceTestStruct] )


  for acceptance_test <- test_case_data do
    @tag :acceptance 
    @tag :"example_#{acceptance_test.example}"
    test "Acceptance Tests -- Section #{acceptance_test.section} (#{acceptance_test.example})\n---\n#{acceptance_test.markdown}\n---\n" do

      result =
        if Regex.match?( ~r/\A1\.0/, System.version ) do
          Earmark.to_html( unquote(acceptance_test.markdown), %Earmark.Options{smartypants: false} )
        else
          IgnoreOutput.in_fun :standard_error, fn ->
            Earmark.to_html( unquote(acceptance_test.markdown), %Earmark.Options{smartypants: false} )
          end
        end

      assert result == unquote(acceptance_test.html)
    end
  end

end
