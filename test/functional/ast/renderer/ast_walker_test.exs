defmodule Functional.Ast.Renderer.AstWalkerTest do
  use ExUnit.Case

  import Earmark.Ast.Renderer.AstWalker

  @up &String.upcase/1
  describe "Walking a simple ast" do
    test "empty" do
      assert walk_ast([], @up) == []
    end

    test "some strings" do
      assert walk_ast(~w{hello world}, @up) == ~w{HELLO WORLD}
    end

    test "nodes" do
      nodes =    [{"p", [{"class", "hello"}], ~w{alpha beta}}, "gamma"]
      expected = [{"p", [{"class", "hello"}], ~w{ALPHA BETA}}, "GAMMA"]
      assert walk_ast(nodes, @up) == expected
    end
  end

  @split &String.split/1
  describe "Managing complexion" do
    test "getting to two levels" do
      assert walk_ast(["a b", "alpha beta"], @split) == ["a", "b", "alpha", "beta"]
    end

    test "same in a tree" do
      nodes =    [{"p",[], ["a b", {"b", [], ["c d"]}]}]
      expected = [{"p",[], ["a", "b", {"b", [], ~w{c d}}]}]
      assert walk_ast(nodes, @split) == expected
    end
  end

  @br {"br", [], []}
  describe "Creating subtrees" do
    test "create a tree with broken up lines" do
      nodes =    [{"p",[], ["a.b", {"b", [], ["c.d"]}]}]
      expected = [{"p",[], ["a", @br, "b", {"b", [], ["c", @br, "d"]}]}]
      assert walk_ast(nodes, &split_lines/1) == expected
    end

  end

  defp split_lines(line) do
    line
    |> String.split(".")
    |> Enum.intersperse(@br)
  end

end
