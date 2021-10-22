defimpl Collectable, for: Earmark.Options do
  def into(option) do
    collector_fn = fn
      acc, {:cont, {key, value}} ->
        Map.put(acc, key, value)

      acc, :done ->
        acc

      _acc, :halt ->
        :ok
    end

    {option, collector_fn}
  end
end
#  SPDX-License-Identifier: Apache-2.0
