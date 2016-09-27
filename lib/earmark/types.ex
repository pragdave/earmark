defmodule Earmark.Types do

  defmacro __using__(_options \\ []) do
    quote do
      @type token  :: {atom, String.t}
      @type tokens :: list(token)
      @type numbered_line :: %{line: String.t, lnb: number}
      @type maybe(t) :: t | nil
      @type inline_code_continuation :: {nil | String.t, number}
    end
  end

end
