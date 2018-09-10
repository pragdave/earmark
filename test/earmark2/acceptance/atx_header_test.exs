defmodule Earmark2.Acceptance.AtxHeaderTest do
  use ExUnit.Case
  use Support.Macros
  
  describe "from one to six" do
    assert_ast "# one\n## two",
               [{:h1, [], ["one"]}, {:h2, [], ["two"]}]
  end
end
