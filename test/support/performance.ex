defmodule Support.Performance do
  
  @moduledoc """
  Create data for performance tests
  """

  @doc """
  Creates a list as follows:

      make_list([{"1.", 3}, {"-", 2}, {"*", 3}])
      1. 1
         - 1
           * 1
           * 2
           * 3
         - 2
           * 1
           * 2
           * 3
         ...
      1. 2
         - 1
           * 1
           * 2
           ...
      1. 3
      ...
  """
  def make_list(elements_per_level) do
    _make_list(elements_per_level, 0)
    |> IO.iodata_to_binary
  end

  @doc """
  Simply converts a file from `test/fixtures`

      convert_file("medium.md") #=> returns the AST
      convert_file("medium.md", :html, 10) #=> returns the HTML of 10 times the file
  """
  def convert_file(filename, format \\ :ast, count \\ 1) do
    content = File.read!(Path.join("test/fixtures", filename))
    content1 = Stream.cycle([content]) |> Enum.take(count) |> Enum.join("\n")
    {:ok, ast, []} = Earmark.as_ast(content1)
    case format do
      :ast -> ast
      :html -> ast |> Earmark.Transform.transform
    end
  end
  defp _make_list(elements_per_level, indent)
  defp _make_list([{header, n}], indent) do
    prefix = Stream.cycle([" "])|>Enum.take(indent)
    (1..n)
    |> Enum.map(fn number -> [prefix, "#{header} #{number}\n"] end)
  end
  defp _make_list([{header, n}|rest], indent) do
    prefix = Stream.cycle([" "])|>Enum.take(indent)
    new_indent = indent + String.length(header) + 1
    (1..n)
    |> Enum.map(fn number -> [ prefix, "#{header} #{number}\n", _make_list(rest, new_indent)] end)
  end

end
