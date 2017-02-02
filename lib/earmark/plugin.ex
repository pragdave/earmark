defmodule Earmark.Plugin do
  alias Earmark.Error
  alias Earmark.Options

  @moduledoc """
  Plugins are modules that implement a render function. Right now that is `as_html`.

  ### API

  #### Plugin Registration

  When invoking `Earmark.as_html(some_md, options)` we can register plugins inside the `plugins` map, where
  each plugin is a value pointed to by the prefix triggering it.

  Prefixes are appended to `"$$"` and lines starting by that string will be rendered by the registered plugin.

  `%Earmark.Options{plugins: %{"" => CommentPlugin}}` would trigger the `CommentPlugin` for each block of
  lines prefixed by `$$`, while `%Earmark.Options{plugins: %{"cp" => CommentPlugin}}` would do the same for
  blocks of lines prefixed by `$$cp`.

  Please see the documentation of `Plugin.define` for a convenience function that helps creating the necessary
  `Earmark.Options` structs for the usage of plugins.

  #### Plugin Invocation

  `as_html` (or other render functions in the future) is invoked with a list of pairs containing the text
  and line number of the lines in the block. As an example, if our plugin was registered with the default prefix
  of `""` and the markdown to be converted was:

        # Plugin output ahead
        $$ line one
        $$
        $$ line two

  `as_html` would be invoked as follows:

        as_html([{"line one", 2}, {"", 3}, {"line two", 4})

  #### Plugin Output

  Earmark's render function will invoke the plugin's render function as explained above. It can then integrate the
  return value of the function into the generated rendering output if it complies to the following criteria.

  1. It returns a string
  1. It returns a list of strings
  1. It returns a pair of lists containing a list of strings and a list of error/warning tuples.
  Where the tuples are of the form `{:error | :warning, line_number, descriptive_text}`

  #### A complete example

        iex> defmodule MyPlug do
        ...>   def as_html(lines) do
        ...>     # to demonstrate the three possible return values
        ...>     case render(lines) do
        ...>       {[line], []} -> line
        ...>       {lines, []} -> lines
        ...>       tuple       -> tuple
        ...>     end
        ...>   end
        ...>
        ...>   defp render(lines) do
        ...>     Enum.map(lines, &render_line/1) |> Enum.partition(&ok?/1)
        ...>   end
        ...>
        ...>   defp render_line({"", _}), do: "<hr/>"
        ...>   defp render_line({"line one", _}), do: "<p>first line</p>\\n"
        ...>   defp render_line({line, lnb}), do: {:error, lnb, line}
        ...>
        ...>   defp ok?({_, _, _}), do: false
        ...>   defp ok?(_), do: true
        ...> end
        ...>
        ...> lines = [
        ...>   "# Plugin Ahead",
        ...>   "$$ line one",
        ...>   "$$",
        ...>   "$$ line two",
        ...> ]
        ...> Earmark.as_html(lines, Earmark.Plugin.define(MyPlug))
        {:error, "<h1>Plugin Ahead</h1>\\n<p>first line</p>\\n<hr/>", [{ :error, 4, "line two"}]}

  #### Plugins, reusing Earmark

  As long as you avoid endless recursion there is absolutely no problem to call `Earmark.as_html` in your plugin, consider the following
  example in which the plugin will parse markdown and render html verbatim (which uis stupid, that is what Earmark already does for you,
  but just to demonstrate the possibilities):

        iex> defmodule Again do
        ...>   def as_html(lines) do
        ...>     text_lines = Enum.map(lines, fn {str, _} -> str end)
        ...>     {_, html, errors} = Earmark.as_html(text_lines)
        ...>     { Enum.join([html | text_lines]), errors }
        ...>   end
        ...> end
        ...>  lines = [
        ...>    "$$a * one",
        ...>    "$$a * two",
        ...>  ]
        ...>  Earmark.as_html(lines, Earmark.Plugin.define({Again, "a"}))
        {:ok, "<ul>\\n<li>one\\n</li>\\n<li>two\\n</li>\\n</ul>\\n* one* two", []}
  """

  @doc """
  adds the definition of one or more plugins to `Earmark.Options`.

  If the plugin is defined with the default prefix and no other options are needed
  one can use the one parameter form:

      iex> Earmark.Plugin.define(Earmark) # not a legal plugin of course
      %Earmark.Options{plugins: %{"" => Earmark}}

  More then one plugin can be defined, as long as all prefixes differ

      iex> defmodule P1, do: nil
      ...> defmodule P2, do: nil
      ...> Earmark.Plugin.define([ Earmark, {P1, "p1"}, {P2, "p2"} ])
      %Earmark.Options{plugins: %{"" => Earmark, "p1" => Unit.PluginTest.P1, "p2" => Unit.PluginTest.P2}}

  """
  def define(plugin_defs)
  def define(plugin_defs), do: define(%Options{}, plugin_defs)


  def define(options, plugin_defs)

  def define(options, plugins) when is_list(plugins) do
    Enum.reduce(plugins, options, fn plugin, acc -> define(acc, plugin) end)
  end
  def define(options=%Options{plugins: plugins}, {plugin, prefix}) do
    if Map.get(plugins, prefix) do
      raise Error, "must not define more than one plugin for prefix #{inspect prefix}"
    else
      %{options | plugins: Map.put(plugins, prefix, plugin)}
    end
  end
  def define(options, plugin), do: define(options, {plugin, ""})
end
