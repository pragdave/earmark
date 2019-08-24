defmodule Earmark.Ast.Renderer.AstWalker do
  
  @moduledoc false

  def walk_ast(ast, fun), do: _walk_ast(ast, fun, [])


  defp _walk_ast(ast, fun, res)
  defp _walk_ast([], _fun, res), do: Enum.reverse(res)
  defp _walk_ast(stringy, fun, res) when is_binary(stringy), do: _walk_ast([stringy], fun, res)
  defp _walk_ast([stringy|rest], fun, res) when is_binary(stringy) do
    res1 = 
    case fun.(stringy) do
      []          -> res
      [_|_]=trans -> List.flatten([Enum.reverse(trans)|res])
      stringy1    -> [stringy1|res]
    end
    _walk_ast(rest, fun, res1)
  end
  defp _walk_ast([{tag, atts, content}|rest], fun, res) do
    _walk_ast(rest, fun, [{tag, atts, _walk_ast(content, fun, [])}|res])
  end
  defp _walk_ast([list|rest], fun, res) when is_list(list) do
    _walk_ast(rest, fun, [_walk_ast(list, fun, [])|res])
  end
end
