defmodule HeadingsTest do
  use ExUnit.Case

  alias Earmark.HtmlRenderer, as: Renderer
  alias Earmark.Block.Heading

  import Support.Helpers


  defp render [level: level, content: content] do
    with {_, value} <- Renderer.render([
      %Heading{attrs: nil, level: level, content: content}],
      updated_context()
    ) do
      value
    end
  end

  defp updated_context do
   Earmark.Context.update_context( context() )
  end


  def expected text, level: level do
    "<h#{level}>#{text}</h#{level}>\n"
  end

  test "Basic Heading without inline markup" do
    result = render( level: 1, content: "Plain Text" )
    assert result == expected( "Plain Text", level: 1 )
  end

  test "Basic Heading without inline markup (level 6)" do
    result = render( level: 6, content: "Plain Text" )
    assert result == expected( "Plain Text", level: 6 )
  end

  test "Heading with emphasis" do
    result = render( level: 6, content: "some _emphasis_ is a good thing" )
    assert result == expected("some <em>emphasis</em> is a good thing", level: 6 )
  end

  test "Heading with strong" do
    result = render( level: 2, content: "Elixir makes a **strong** impression" )
    assert result == expected( "Elixir makes a <strong>strong</strong> impression", level: 2 )
  end

  test "Heading with code" do
    result = render( level: 3, content: "Elixir `code` is beautiful" )
    assert result == expected( ~s[Elixir <code class="inline">code</code> is beautiful], level: 3 )
  end

end
