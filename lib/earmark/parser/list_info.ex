defmodule Earmark.Parser.ListInfo do
  @moduledoc false

  @not_pending {nil, 0}

  defstruct(
    indent: 0,
    pending: @not_pending,
    spaced: false,
    width: 0)

  def new(%Earmark.Line.ListItem{initial_indent: ii, list_indent: width}), do: %__MODULE__{indent: ii, width: width}
end
