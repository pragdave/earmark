defmodule Earmark.SysInterface.Implementation do

  @behaviour Earmark.SysInterface.Behavior

  @doc """
  A proxy to IO.stream(..., :line)
  """
  def readlines(device), do: IO.stream(device, :line)
end
#  SPDX-License-Identifier: Apache-2.0
