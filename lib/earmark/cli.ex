defmodule Earmark.Cli do


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
    |> Earmark.Cli.Implementation.run()
    |> output()
  end

  defp output({device, string}) do
    IO.puts(device, string)
    if device == :stderr, do: exit(1)
  end
end
#  SPDX-License-Identifier: Apache-2.0
