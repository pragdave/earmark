defmodule Support.ErrorPlugin do

  def as_html(lines) do
    if Enum.all?(lines, &correct?/1) do
      "<strong>correct</strong>\n"
    else
      { for line <- lines, correct?(line) do "<strong>correct</strong>" end,
        for line <- lines, !correct?(line) do make_error(line) end }
    end
  end

  defp correct?({line, _}), do: line == "correct"
  defp make_error({_, lnb}), do: {:error, lnb, "that is incorrect"}
end

# SPDX-License-Identifier: Apache-2.0
