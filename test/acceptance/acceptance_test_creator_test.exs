defmodule AcceptanceTestCreatorTest do
  use ExUnit.Case

  alias Support.AcceptanceTestStruct

  test_case_data =
  Path.join([__DIR__,"../assets/acceptance_tests.json"])
  |> File.stream!( [], :line )
  |> Enum.reject( &(String.match?(&1, ~r{^\s*(?:#|//)})) )
  |> Enum.join( "\n" )
  |> Poison.decode!( as: [%AcceptanceTestStruct{}] )

  for acceptance_test <- test_case_data do
    @tag :acceptance
    @tag :"example_#{acceptance_test.example}"
    test "Acceptance: #{acceptance_test.section} #{acceptance_test.description} (#{acceptance_test.example})\n---\n#{acceptance_test.markdown}\n---\n" do
      options = %Earmark.Options{smartypants: false}
      result = case Earmark.as_html( unquote(acceptance_test.markdown), options ) do
        {:ok, html} -> {html, []}
        {:error, html, messages} -> {html, messages}
      end
      assert result == {unquote(acceptance_test.html), unquote(acceptance_test.messages)}
    end
  end

end
