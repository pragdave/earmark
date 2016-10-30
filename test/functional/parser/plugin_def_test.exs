defmodule Functional.Parser.PluginDefTest do
  use ExUnit.Case

  alias Earmark.Block, as: B
  alias Earmark.Message, as: M
  alias Earmark.Options, as: O
  
  test "parse plugin definition" do 
    assert parse("$$plugin my_plugin") == {[
      %B.PluginDef{content: "$$plugin my_plugin", plugin: "my_plugin", prefix: "$$"},
      ], [], %{"$$" => {"my_plugin", 1}}}
  end

  test "parse plugin definition with prefix" do 
    assert parse("$$ plugin ur_plugin prefixed Y") == {[
      %B.PluginDef{content: "$$ plugin ur_plugin prefixed Y", plugin: "ur_plugin", prefix: "$$Y"},
    ], [], %{"$$Y" => {"ur_plugin", 1}}}
  end

  test "two plugins" do 
    assert parse("$$plugin my_plugin\n$$ plugin ur_plugin prefixed Y") == {[
      %B.PluginDef{content: "$$plugin my_plugin", plugin: "my_plugin", prefix: "$$"},
      %B.PluginDef{content: "$$ plugin ur_plugin prefixed Y", plugin: "ur_plugin", prefix: "$$Y"},
    ], [], %{"$$" => {"my_plugin", 1}, "$$Y" => {"ur_plugin", 2}}}
    
  end

  test "you shallt not reuse the default prefix, correction: U cannot" do 
    assert parse("$$plugin my_plugin\n$$plugin ur_plugin ") == {[
      %B.PluginDef{content: "$$plugin my_plugin", plugin: "my_plugin", prefix: "$$"},
    ], [ %M{line: 2, text: "cannot reuse already defined prefix \"$$\" for plugin \"ur_plugin\" (used in line 1 by \"my_plugin\")\ntry to use a differnt prefix with \"$$plugin ur_plugin prefixed by `new_prefix`\"", type: :error}
    ], %{"$$" => {"my_plugin", 1}}}
  end

  test "you shallt not reuse a prefix, correction: U cannot" do 
    assert parse("$$plugin my_plugin prefixed by Y\n$$ plugin ur_plugin prefixed Y") == {[
      %B.PluginDef{content: "$$plugin my_plugin prefixed by Y", plugin: "my_plugin", prefix: "$$Y"},
    ], [ %M{line: 2, text: "cannot reuse already defined prefix \"$$Y\" for plugin \"ur_plugin\" (used in line 1 by \"my_plugin\")\ntry to use a differnt prefix with \"$$plugin ur_plugin prefixed by `new_prefix`\"", type: :error}
    ], %{"$$Y" => {"my_plugin", 1}}}
  end
  test "parser is already plugin aware" do 
    assert parse("$$ plugin no_plugin prefixed Y") == {[],
      [
        %M{line: 1, text: "no entry for \"no_plugin\" in options.plugins; plugin definition ignored", type: :error}
      ], %{}
    }
  end

  defp parse str do 
      case Earmark.parse(str, %O{plugins: %{my_plugin: O, ur_plugin: O}}) do
      {blx, _, opts} -> {blx, opts.messages, opts.plugin_prefixes}
    end
  end
end
