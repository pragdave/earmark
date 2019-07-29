defmodule Earmark.Plugin do
  alias Earmark.Error
  alias Earmark.Options

  @moduledoc """
  DEPRECATED!!!
  """

  @doc """
  DEPRECATED!!!

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

# SPDX-License-Identifier: Apache-2.0
