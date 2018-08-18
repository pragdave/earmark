defmodule Functional.Parser.Earmark2.AstTest do
  use ExUnit.Case

  import Earmark2.Parser
  doctest Earmark2.Parser, import: true

  describe "single node" do 
    test "empty" do
      assert parse_doc("") == {[], []}
    end

    test "simple" do
      assert parse_doc("hello") == {[{:para, [{:verb, "hello", 1, 1}]}], []}
    end
  end

  describe "multi node" do
    test "two verbs" do
      assert parse_doc("hello\nworld") == {[{:para, [{:verb, "hello", 1, 1}, {:verb, "world", 2, 1}]}], []}

    end
  end


  defp parse_doc doc do
    with %{nodes: nodes, errors: errors} <- parse_document(doc), do: {nodes, errors}
  end
end
