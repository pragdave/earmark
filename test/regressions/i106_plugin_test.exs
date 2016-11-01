defmodule Regressions.I106PluginTest do
  use ExUnit.Case

  import Earmark, only: [as_html: 2]
  alias Earmark.Options
  alias Earmark.Plugin
  
  @comment_md """
  $$ this is a comment
  """
  test "the comment plugin" do 
    assert as_html(@comment_md, %Options{plugins: %{comment: CommentPlugin}}) ==
      { :ok, "<!-- this is a comment -->" }
  end

  @comments_md """
  $$c comment one
  $$c comment two
  $$unregistered plugin
  $$c comment three
  """
  test "more lines" do 
    assert as_html(@comments_md, Plugin.define({CommentPlugin, "c"})) ==
    { :error, "<!-- comment one\n     comment two -->\n<!-- comment three -->\n", ["<no file>:4:ignoring unregistered plugin line for prefix \"$$\""]}
  end

  @more_md """
  line one
  $$ comment one
  $$c
  line two
  """
  test "even more lines" do 
    assert as_html(@comments_md, Plugin.define(%Options{}, [CommentPlugin])) ==
    { :error, "<p>line one</p>\n<!-- comment one -->\n<p>line two</p>\n", ["<no file>:4:ignoring unregistered plugin line for prefix \"$$c\""]}
  end
end
