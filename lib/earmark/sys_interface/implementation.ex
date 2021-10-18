defmodule Earmark.SysInterface.Implementation do

  @behaviour Earmark.SysInterface.Behavior

  @doc """
  A proxy to IO.stream(..., :line)
  """
  @impl true
  def readlines(device_or_filename)
  def readlines(filename) when is_binary(filename) do
    case File.open(filename, [:utf8]) do
      {:ok, device} = device -> readlines(device)
      {:error, _} = error    -> error
    end
  end
  def readlines(device), do: IO.stream(device, :line)
end
#  SPDX-License-Identifier: Apache-2.0
