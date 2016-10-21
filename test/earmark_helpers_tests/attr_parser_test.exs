defmodule EarmarkHelpersTests.AttrParserTest do
  use ExUnit.Case
  import Earmark.Helpers.AttrParser

  #
  # describe "without errors" do  # still using Elixir 1.2
  #
  test "empty" do
    assert_parsed_as( %{}, "")
  end
  test "base case" do
    assert_parsed_as(%{"title" => ~w[Pragdave]}, "title=Pragdave")
  end
  test "many base cases" do
    assert_parsed_as(%{"title" => ~w[Pragdave], "alt" => ~w[Control]}, "title=Pragdave alt='Control'")
  end
  test "shortcuts" do
    assert_parsed_as(%{"class" => ~w[80]},".80")
    assert_parsed_as(%{"class" => ~w[80], "id" => ~w[awesome-42]},".80 #awesome-42")
    assert_parsed_as(%{"class" => ~w[80], "id" => ~w[awesome-42]},"#awesome-42 .80")
  end
  test "a wild mix" do
    assert_parsed_as(
      %{
        "alt" => ["motion picture"], "class" => ["satchmo", "crooner", "upperclass"], "id" => ["Doris"], "title" => ["made my Day", "hello"]
      },
      "title='hello' .upperclass .crooner alt=\"motion picture\" #Doris title='made my Day' .satchmo"
    )
  end

  #
  # describe "with errors" do  # still using Elixir 1.2
  #
  test "base case - with errors" do
    assert_parsed_as(%{"title" => ~w[Pragdave]}, "error title=Pragdave", errors: "error" )
    assert_parsed_as(%{"title" => ~w[Pragdave]}, "title=Pragdave error", errors: "error" )
    assert_parsed_as(%{"title" => ~w[Pragdave]}, "error= title=Pragdave error", errors: ~w[error error=] )
  end
  test "many base cases - with errors" do
    assert_parsed_as(%{"title" => ~w[Pragdave], "alt" => ~w[Control]}, "error title=Pragdave alt='Control'", errors: "error")
  end
  test "shortcuts - with errors" do
    assert_parsed_as(%{"class" => ~w[80]},".80 error", errors: "error")
    assert_parsed_as(%{"class" => ~w[80], "id" => ~w[awesome-42]},".80 error #awesome-42", errors: "error")
    assert_parsed_as(%{"class" => ~w[80], "id" => ~w[awesome-42]},"#awesome-42 .80 error", errors: "error")
  end
  test "a wild mix - with errors" do
    assert_parsed_as(
      %{
        "alt" => ["motion picture"], "class" => ["satchmo", "crooner", "upperclass"], "id" => ["Doris"], "title" => ["made my Day", "hello"]
      },
      "title='hello' .upperclass   one% .crooner alt=\"motion picture\" two- #Doris title='made my Day' .satchmo    three",
      errors: ~w[three two- one%]
    )
  end

  defp assert_parsed_as( attrs, str, errors \\ [errors: []]  ) do
    errors = Keyword.get( errors, :errors )
    errors = if is_list(errors), do: errors, else: [errors]
    result = parse_attrs( str )
    assert {attrs, errors} == result
  end
end
