defmodule Support.CommentPlugin do

  def as_html(lines) do
    {["<!-- " | 
      Enum.map(lines, fn {text, _} -> text end) |>
      Enum.intersperse("\n")
    ] ++ [ " -->\n"], []}
  end
  
end
