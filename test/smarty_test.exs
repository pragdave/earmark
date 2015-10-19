defmodule SmartyTest do
  use ExUnit.Case

  alias Earmark.Inline

  ###############
  # Helpers.... #
  ###############

  def context do
    %Earmark.Context{}
  end



  def pedantic_context do
    ctx = put_in(context.options.gfm, false)
    ctx = put_in(ctx.options.pedantic, true)
    Inline.update_context(ctx)
  end

  def gfm_context do
    Inline.update_context(context)
  end

  def convert_pedantic(string) do
    Inline.convert(string, pedantic_context)
  end

  def convert_gfm(string) do
    Inline.convert(string, gfm_context)
  end

  ############################################################
  # Quotes                                                    #
  ############################################################

  test "paired single" do
    result = convert_pedantic("a 'single' quote")
    assert result == "a ‘single’ quote"
  end

  test "apostrophe" do
    result = convert_pedantic("a single's quote")
    assert result == "a single’s quote"
  end

  test "paired single before puncuation" do
    Enum.each '.]})?!', fn (punct) ->
      result = convert_pedantic("a 'single'" <> <<punct>>)
      assert result == "a ‘single’"  <> <<punct>>
    end
  end

  test "paired double" do
    result = convert_pedantic("a \"double\" quote")
    assert result == "a “double” quote"
  end

  test "paired double before puncuation" do
    Enum.each '.]})?!', fn (punct) ->
      result = convert_pedantic("a \"double\"" <> <<punct>>)
      assert result == "a “double”"  <> <<punct>>
    end
  end

  test "closing quotes after tag" do
    result = convert_pedantic ~s(a "**test**")
    assert result == "a “<strong>test</strong>”"
  end

  test "closing single quotes after tag" do
    result = convert_pedantic ~s(a '**test**')
    assert result == "a ‘<strong>test</strong>’"
  end
end
