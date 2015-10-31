defmodule AcceptanceTestCreator do
  use ExUnit.Case

  {:ok, test_case_data } =
    Path.join([__DIR__,"../assets/tests.json"])
    |> File.stream!( [], :line )
    |> Enum.reject( &(String.match?(&1, ~r{^\s*#})) )
    |> Enum.join( "\n" )
    |> Poison.Parser.parse( keys: :atoms ) # We are operating on a json file that is part of the application and contains
    # only four different keys, so keys: :atoms is safe. Nevertheless one might think about decoding the json into a nice
    # struct...

                                           
  for %{section: section, example: example, markdown: markdown, html: html} <- test_case_data do
   @tag :"example_#{example}"
    test "Acceptance Tests -- Section #{section} (#{example})" do
      result = Earmark.to_html unquote(markdown), %Earmark.Options{smartypants: false}
      assert result == unquote(html)
    end
  end

end
