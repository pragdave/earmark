defmodule Support.AstHelpers do
  
  def ast_from_md(md) do
    with {:ok, ast, []} <- Earmark.as_ast(md), do: ast
  end

  def p(content, atts \\ [])
  def p(content, atts) when is_binary(content) or is_tuple(content),
    do: {"p", atts, [content]}
  def p(content, atts),
    do: {"p", atts, content}

  def tag(name, content \\ nil, atts \\ []) do
    {to_string(name), _atts(atts), _content(content)}
  end

  def void_tag(tag, atts \\ []) do
    {to_string(tag), atts, []}
  end


  defp _atts(atts) do
    atts |> Enum.into(Keyword.new) |> Enum.map(fn {x, y} -> {to_string(x), to_string(y)} end)
  end
  
  defp _content(c)
  defp _content(nil), do: []
  defp _content(s) when is_binary(s), do: [s]
  defp _content(c), do: c

end
