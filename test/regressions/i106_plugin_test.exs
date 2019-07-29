defmodule Regressions.I106PluginTest do
  use ExUnit.Case

  import Earmark, only: [as_html: 2]
  alias Earmark.Options
  alias Earmark.Plugin

  alias Support.CommentPlugin
  alias Support.ErrorPlugin
  
  @comment_md """
  $$ this is a comment
  """
  test "the comment plugin" do 
    assert as_html(@comment_md, %Options{plugins: %{"" => CommentPlugin}}) ==
      {:ok, "<!-- this is a comment -->\n", [{:deprecation, "DEPRECATED: Plugins will be removed in Earmark 1.4", 1}] } end 
  @comments_md """
  $$c comment one
  $$c comment two
  $$unregistered plugin
  $$c comment three
  """
  test "more lines" do 
    assert as_html(@comments_md, Plugin.define({CommentPlugin, "c"})) ==
    {:error, "<!-- comment one\ncomment two -->\n<!-- comment three -->\n",
     [{ :warning, 3, "lines for undefined plugin prefix \"unregistered\" ignored (3..3)"},
      {:deprecation, "DEPRECATED: Plugins will be removed in Earmark 1.4", 1},
      {:deprecation, "DEPRECATED: Plugins will be removed in Earmark 1.4", 4}]}
  end

  @more_md """
  line one
  $$ comment one
  $$c
  line two
  """
  test "even more lines" do 
    assert as_html(@more_md, Plugin.define(%Options{}, [CommentPlugin])) ==
    {:error, "<p>line one</p>\n<!-- comment one -->\n<p>line two</p>\n", 
     [{ :warning, 3, "lines for undefined plugin prefix \"c\" ignored (3..3)"},
      {:deprecation, "DEPRECATED: Plugins will be removed in Earmark 1.4", 2}]}
  end

  @mix_errors """
  $$unregistered
  $$ comment
  =
  """
  test "a mix of errors" do 
    assert as_html(@mix_errors, Plugin.define(%Options{}, CommentPlugin)) ==
    {:error, "<!-- comment -->\n<p></p>\n",[
          { :warning, 1, "lines for undefined plugin prefix \"unregistered\" ignored (1..1)"},
            { :warning, 3, "Unexpected line ="},
            {:deprecation, "DEPRECATED: Plugins will be removed in Earmark 1.4", 2}]}
  end

  @error_plugin """
  $$c comment
  data
  $$ correct
  $$ incorrect
  $$undef
  """
  test "a plugin with errors" do
    options = Plugin.define(%Options{}, [ErrorPlugin, {CommentPlugin, "c"}])
    assert as_html(@error_plugin, options) ==
    {:error, "<!-- comment -->\n<p>data</p>\n<strong>correct</strong>", [
          {:error, 4, "that is incorrect" },
          {:warning, 5, "lines for undefined plugin prefix \"undef\" ignored (5..5)"},
        {:deprecation, "DEPRECATED: Plugins will be removed in Earmark 1.4", 1}, {:deprecation, "DEPRECATED: Plugins will be removed in Earmark 1.4", 3}]}
  end
end

# SPDX-License-Identifier: Apache-2.0
