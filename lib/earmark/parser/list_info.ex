defmodule Earmark.Parser.ListInfo do
  import Earmark.Helpers.LookaheadHelpers, only: [opens_inline_code: 1, still_inline_code: 2]

  @moduledoc false

  @not_pending {nil, 0}

  # @derive {Inspect, only: [:pending, :width]}
  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(subject, opts)
    def inspect(%{pending: {nil, _}}=subject, opts) do
      concat(["LInfo<", "width: ", to_doc(subject.width, opts), ">"])
    end
    def inspect(%{pending: {pending, _}}=subject, opts) do
      concat(["LInfo<", "width: ", to_doc(subject.width, opts), " pending: ", to_doc(pending, opts), ">"])
    end
  end

  defstruct(
    indent: 0,
    pending: @not_pending,
    spaced: false,
    width: 0)

  # INLINE CANDIDATE
  def new(%Earmark.Line.ListItem{initial_indent: ii, list_indent: width}=item) do
    pending = opens_inline_code(item)
    %__MODULE__{indent: ii, pending: pending, width: width}
  end

  # INLINE CANDIDATE
  def update_pending(list_info, line)
  def update_pending(%{pending: @not_pending}=info, line) do
    pending = opens_inline_code(line)
    %{info | pending: pending}
  end
  def update_pending(%{pending: pending}=info, line) do
    pending1 = still_inline_code(line, pending)
    %{info | pending: pending1}
  end
end
