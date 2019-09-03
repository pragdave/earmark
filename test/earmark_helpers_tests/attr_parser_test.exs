defmodule EarmarkHelpersTests.AttrParserTest do
  use ExUnit.Case, async: true
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
  describe "base case - with errors" do
    test "bare error" do
      assert_parsed_as(%{"title" => ~w[Pragdave]}, "error title=Pragdave", errors: "error" )
    end
    test "error at end" do
      assert_parsed_as(%{"title" => ~w[Pragdave]}, "title=Pragdave error", errors: "error" )
    end
    test "two errors" do
      assert_parsed_as(%{"title" => ~w[Pragdave]}, "error= title=Pragdave error", errors: ~w[error error=] )
    end
  end
  test "many base cases - with errors" do
    assert_parsed_as(%{"title" => ~w[Pragdave], "alt" => ~w[Control]}, "error title=Pragdave alt='Control'", errors: "error")
  end
  describe "shortcuts - with errors" do
    test "class 80" do
      assert_parsed_as(%{"class" => ~w[80]},".80 error", errors: "error")

    end
    test "awesome 42" do
      assert_parsed_as(%{"class" => ~w[80], "id" => ~w[awesome-42]},".80 error #awesome-42", errors: "error")
    end

    test "awesome id" do
      assert_parsed_as(%{"class" => ~w[80], "id" => ~w[awesome-42]},"#awesome-42 .80 error", errors: "error")
    end
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
    {context, result} = parse_attrs( %Earmark.Context{}, str, 0 )
    assert attrs == result
    unless Enum.empty?(errors) do
      expected = [{:warning, 0, "Illegal attributes #{inspect errors} ignored in IAL"}]
      assert context.options.messages == expected
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
