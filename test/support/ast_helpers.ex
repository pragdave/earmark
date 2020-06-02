defmodule Support.AstHelpers do
  
  def ast_from_md(md) do
    with {:ok, ast, []} <- Earmark.as_ast(md), do: ast
  end

  def p(content, atts \\ [])
  def p(content, atts) when is_binary(content) or is_tuple(content),
    do: {"p", atts, [content]}
  def p(content, atts),
    do: {"p", atts, content}


  def void_tag(tag, atts \\ []) do
    {to_string(tag), atts, []}
  end
end
