defmodule Acceptance.ParserApiTest do
  use ExUnit.Case

  describe "Seemingless Integration of EarmarkParser.as_ast" do
    @ast {:ok, [], []}
    @markdown ""
    test "can be called by client code" do
      assert EarmarkParser.as_ast(@markdown) == @ast
    end
    test "still using Options" do
      assert EarmarkParser.as_ast(@markdown, %Earmark.Options{}) == @ast
    end
  end
end
