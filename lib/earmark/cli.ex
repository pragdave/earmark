defmodule Earmark.CLI do

  alias Earmark.CLI.Implementation

  @moduledoc """
  The Earmark CLI

  Entry point of the escript, this is the **only** point that does IO with output and it uses the `Earmark.File` module which
  is the **only** point that does IO with input.

  """
  @doc """
  This is the entry point of the escript
  """
  def main(argv) do
    argv
    |> Implementation.run()
    |> output()
    |> exit()
  end

  defp output({device, string}) do
    IO.puts(device, string)
    if device == :stderr, do: 1, else: 0
  end
end
#  SPDX-License-Identifier: Apache-2.0
