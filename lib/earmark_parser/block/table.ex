defmodule EarmarkParser.Block.Table do
  @moduledoc false
  defstruct lnb: 0, annotation: nil, attrs: nil, rows: [], header: nil, alignments: []

  def new_for_columns(n) do
    %__MODULE__{alignments: Elixir.List.duplicate(:left, n)}
  end
end
#  SPDX-License-Identifier: Apache-2.0
