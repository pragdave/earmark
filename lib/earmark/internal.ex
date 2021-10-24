defmodule Earmark.Internal do

  alias Earmark.Error
  @moduledoc ~S"""
  All public functions that are internal to Earmark, so that **only** external API
  functions are public in `Earmark`
  """

  @default_timeout_in_ms 5000
  @doc false
  def pmap(collection, func, timeout \\ @default_timeout_in_ms) do
    collection
    |> Enum.map(fn item -> Task.async(fn -> func.(item) end) end)
    |> Task.yield_many(timeout)
    |> Enum.map(&_join_pmap_results_or_raise(&1, timeout))
  end

  defp _join_pmap_results_or_raise(yield_tuples, timeout)
  defp _join_pmap_results_or_raise({_task, {:ok, result}}, _timeout), do: result

  defp _join_pmap_results_or_raise({task, {:error, reason}}, _timeout),
    do: raise(Error, "#{inspect(task)} has died with reason #{inspect(reason)}")

  defp _join_pmap_results_or_raise({task, nil}, timeout),
    do:
      raise(
        Error,
        "#{inspect(task)} has not responded within the set timeout of #{timeout}ms, consider increasing it"
      )

end
#  SPDX-License-Identifier: Apache-2.0
