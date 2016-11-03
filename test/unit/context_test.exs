defmodule Unit.ContextTest do
  use ExUnit.Case
  
  alias Earmark.Context, as: C

  test "no messages" do 
    assert C.messages(%C{}) == []
  end

  test "some messages" do 
    assert C.messages(C.add_messages(%C{}, [:a, :b])) == [:a, :b]
  end

  test "more messages" do 
   c = C.add_messages(
      C.add_messages(%C{}, [:one, :two]), :three)
   assert C.messages(c) == [:one, :two, :three]
   assert c.options.messages == [:one, :two, :three]
  end
end
