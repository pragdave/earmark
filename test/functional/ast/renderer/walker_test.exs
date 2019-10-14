defmodule Functional.Ast.Renderer.WalkerTest do
  use ExUnit.Case

  import Earmark.Ast.Renderer.AstWalker

  @up &String.upcase/1

  test "demonstration of the usage of the general walker" do
    data = [%{"a" => "alpha", "b" => "beta"}, {"gamma"}, "delta"]

    assert walk(data, @up) == [%{"A" => "ALPHA", "B" => "BETA"}, {"GAMMA"}, "DELTA"]
  end
  
  test "demonstration of the usage of the general walker, ignore hash keys" do
    data = [%{a: "alpha", b: "beta"}, {"gamma"}, "delta"]

    assert walk(data, @up, true) == [%{a: "ALPHA", b: "BETA"}, {"GAMMA"}, "DELTA"]
  end
  
end
