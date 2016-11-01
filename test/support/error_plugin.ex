defmodule Support.ErrorPlugin do
  
  def as_html(lines) do 
    if Enum.all?(lines, &correct?/1) do
      "<strong>correct</strong>\n"
    else
      { Enum.filter_map(lines, &correct?/1, fn _ -> "<strong>correct</strong>" end),
        Enum.filter_map(lines, &(!correct?(&1)), &make_error/1)}
    end
  end

  defp correct?({line, _}), do: line == "correct"
  defp make_error({_, lnb}), do: {:error, lnb, "that is incorrect"}
end
