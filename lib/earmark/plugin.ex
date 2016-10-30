defmodule Earmark.Plugin do
  alias Earmark.Options

  defmodule Error do
    defexception [:message]

    def exception(msg), do: %__MODULE__{message: msg}
  end

  @doc """
  adds the definition of one or more plugins to `Earmark.Options`.

  If the plugin is defined with the default prefix and no other options are needed
  one can use the one parameter form:

      iex> Earmark.Plugin.define(Earmark) # not a legal plugin ofg course
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
