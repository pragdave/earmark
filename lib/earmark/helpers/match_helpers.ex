defmodule Earmark.Helpers.MatchHelpers do
  defmacro pattern_fn(pattern) do
    quote do
      fn
        unquote(pattern) -> true
        _                -> false
      end
    end
  end
end
