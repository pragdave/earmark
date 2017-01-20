defmodule Functional.Parser.PluginTest do
  use ExUnit.Case

  alias Earmark.Block
  alias Earmark.Context
  alias Earmark.Plugin

  defmodule Plug, do: nil

  test "no plugins" do 
    assert parse("a") == {
      [%Block.Para{attrs: nil, lines: ["a"], lnb: 1}], []
    }
  end

  test "single plugin line" do 
    assert parse("$$") == {
      [ %Block.Plugin{prefix: "", lines: [{"", 1}], handler: Block, lnb: 1} ], []
    }
  end


  test "plugin line block" do 
    {[ %Block.Para{lines: pre_lines},
       plugin_block,
       %Block.Para{lines: post_lines},
      ], [] } =  parse("pre\n$$\n$$ alpha\n$$ beta\npost")
    assert pre_lines == ~w(pre)
    assert post_lines == ~w(post)
    assert plugin_block == 
      %Block.Plugin{lnb: 2, prefix: "", lines: [{"", 2}, {"alpha", 3}, {"beta", 4}], handler: Block}
  end

  @plugin_markdown """
  one
  $$ default one
  $$msg prefix one
  $$msg
  * two
  * three
  $$ default two
  $$ default three
  """
  test "plugin line blocks" do 
    {[ %Block.Para{lines: pre_lines},
       default_plugin_block,
       prefix_plugin_block,
       %Block.List{},
       other_default_block
      ], [] } =  parse(@plugin_markdown)
    assert pre_lines == ~w(one)
    assert default_plugin_block == 
      %Block.Plugin{lnb: 2, prefix: "", lines: [{"default one", 2}], handler: Block}
    assert prefix_plugin_block ==
      %Block.Plugin{lnb: 3, prefix: "msg", handler: Plug,
                 lines: [{"prefix one", 3}, {"", 4}]}
    assert other_default_block ==
      %Block.Plugin{lnb: 7, prefix: "", handler: Block, lines: [{"default two", 7}, {"default three", 8}]}
  end

  @undefined_plugin """
  one
  $$ default one
  $$udf prefix one
  $$udf
  $$msg
  * two
  * three
  $$ default two
  $$ default three
  $$yud blah blah
  """
  test "plugin line blocks with undefined" do 
    {[ %Block.Para{lines: pre_lines},
       default_plugin_block,
       prefix_plugin_block,
       %Block.List{},
       other_default_block
      ], messages } =  parse(@undefined_plugin)
    assert pre_lines == ~w(one)
    assert default_plugin_block == 
      %Block.Plugin{lnb: 2, prefix: "", lines: [{"default one", 2}], handler: Block}
    assert prefix_plugin_block ==
      %Block.Plugin{lnb: 5, prefix: "msg", handler: Plug,
                 lines: [{"", 5}]}
    assert other_default_block ==
      %Block.Plugin{lnb: 8, prefix: "", handler: Block, lines: [{"default two", 8}, {"default three", 9}]}
    assert messages == 
      [{ :warning, 10, "lines for undefined plugin prefix \"yud\" ignored (10..10)" }, { :warning, 3, "lines for undefined plugin prefix \"udf\" ignored (3..4)" }]
  end


  defp parse(lines) do
    {blocks, ctxt} =
      Earmark.parse(lines, Plugin.define([ Block, {Plug, "msg"}, {Plugin, "pg"} ]))
    {blocks, Context.messages(ctxt)}
  end
end
