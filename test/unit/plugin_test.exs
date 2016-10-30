defmodule Unit.PluginTest do
  use ExUnit.Case

  alias Earmark.Options, as: O
  alias Earmark.Plugin, as: P
  alias Earmark.Plugin.Error, as: E

  doctest P

  test "raises error in case default prefix is reused" do 
    assert_raise( E, "must not define more than one plugin for prefix \"\"", fn ->
      P.define([E, E])
    end)
    
    assert_raise( E, "must not define more than one plugin for prefix \"\"", fn ->
      P.define([E, {E, "e"}, E])
    end)

    assert_raise( E, "must not define more than one plugin for prefix \"\"", fn ->
      P.define(%O{}, [E, {E, "e"}, E])
    end)
  end

  test "raises error in case prefix is reused" do 
    assert_raise( E, "must not define more than one plugin for prefix \"pfx\"", fn ->
      P.define([E, {E, "pfx"}, {O, "pfx"}])
    end)
    
    assert_raise( E, "must not define more than one plugin for prefix \"pfx\"", fn ->
      P.define([{"hello", "pfx"}, E, {E, "e"}, {E, "pfx"}])
    end)

    assert_raise( E, "must not define more than one plugin for prefix \"pfx\"", fn ->
      P.define(%O{}, [E, {E, "pfx"}, {E, "pfx"} ])
    end)
  end

end
