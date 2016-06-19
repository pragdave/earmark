defmodule Earmark.Types do

  defmacro __using__(_options \\ []) do
    quote do
      @type maybe(t) :: t | nil
    end
  end

end
