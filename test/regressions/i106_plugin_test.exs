defmodule Regressions.I106PluginTest do
  use ExUnit.Case

  import Earmark, only: [as_html: 2]
  alias Earmark.Options
  
  @comment_md """
  $$plugin comment
  $$ this is a comment
  """
  test "the comment plugin" do 
    assert as_html(@comment_md, %Options{plugins: %{comment: CommentPlugin}}) ==
      { :ok, "<!-- this is a comment -->" }
  end
end
