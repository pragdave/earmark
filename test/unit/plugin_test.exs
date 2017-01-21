defmodule Unit.PluginTest do
  use ExUnit.Case

  alias Earmark.Options, as: O
  alias Earmark.Plugin, as: P
  alias Earmark.Error, as: E

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

  test "plugin_for_prefix default defined" do 
    assert O.plugin_for_prefix(P.define(E), "") == E
  end
  test "plugin_for_prefix pfx undefined" do
    assert O.plugin_for_prefix(P.define(E), "pfx") == false
  end
  test "plugin_for_prefix default undefined" do
    assert O.plugin_for_prefix(P.define({E, "pfx"}), "") == false
  end
  test "plugin_for_prefix pfx defined" do
    assert O.plugin_for_prefix(P.define({E, "pfx"}), "pfx") == E
  end
  test "plugin_for_prefix pfx and default defined" do
    assert O.plugin_for_prefix(P.define([E, {O, "pfx"}]), "pfx") == O
    assert O.plugin_for_prefix(P.define(%O{}, [E, {O, "pfx"}]), "pfx") == O
  end

end
