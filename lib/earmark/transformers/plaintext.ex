defmodule Earmark.Transformers.Plaintext do

  @doc """
  Transforms markdown to plaintext.

      iex(1)> markdown_to_plaintext("# hello")
      {:ok, "hello", []}

  In case errors are encountered during the parsing pass, no transformation is
  performed, and the errors and the ast are returned

      iex(2)> markdown_to_plaintext("[hello](world){:blah}")
      {:error, [{\"p\", [], [{\"a\", [{\"href\", \"world\"}], [\"hello\"]}]}], [{:warning, 1, \"Illegal attributes [\\"blah\\"] ignored in IAL\"}]}
  """
  def markdown_to_plaintext(markdown) do 
    Earmark.Transform.transform_markdown(markdown, &ast_to_plaintext/2)
  end

  @doc """
  Transforms an ast to plaintext, this is useful if the ast has been processed before.

  E.g. all strong elements have been marked again

      iex(3)> [{"p", [], ["a ", {"strong", [], ["**b**"]}, " c"]}]|>ast_to_plaintext()
      \"a **b** c\" 
  """
  def ast_to_plaintext(ast, _options\\nil) do
    ast
    |> Enum.map(&node_to_plaintext/1)
    |> IO.chardata_to_string
  end


  defp node_to_plaintext(node)
  defp node_to_plaintext(node) when is_binary(node), do: node
  defp node_to_plaintext({_tag, _attr, ast}), do: ast_to_plaintext(ast, nil)
  defp node_to_plaintext({_tag, _attr, ast, _meta}), do: ast_to_plaintext(ast, nil)
end
