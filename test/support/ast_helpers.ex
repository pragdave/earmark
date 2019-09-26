defmodule Support.AstHelpers do
  
  def p(content, atts \\ [])
  def p(content, atts) when is_binary(content),
    do: {"p", atts, [content]}
  def p(content, atts),
    do: {"p", atts, content}


  def void_tag(tag, atts \\ []) do
    {to_string(tag), atts, []}
  end
end
