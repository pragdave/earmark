defmodule Functional.Parser.PluginDefTest do
  use ExUnit.Case

  alias Earmark.Block, as: B
  alias Earmark.Message, as: M
  alias Earmark.Options, as: O
  
  test "parse plugin definition" do 
    assert parse("$$plugin my_plugin") == {[
      %B.PluginDef{content: "$$plugin my_plugin", plugin: "my_plugin", prefix: "$$"},
      ], []}
  end

  test "parse plugin definition with prefix" do 
    assert parse("$$ plugin ur_plugin prefixed Y") == {[
      %B.PluginDef{content: "$$ plugin ur_plugin prefixed Y", plugin: "ur_plugin", prefix: "$$Y"},
    ], []}
  end

  test "parser is already plugin aware" do 
    assert parse("$$ plugin no_plugin prefixed Y") == {[],
      [ %M{line: 1, text: "no entry for \"no_plugin\" in options.plugins; plugin definition ignored", type: :error} ]}
  end

  defp parse str do 
  case Earmark.parse(str, %O{plugins: %{my_plugin: O, ur_plugin: O}}) do
      {blx, _, opts} -> {blx, opts.messages}
    end
  end
end
