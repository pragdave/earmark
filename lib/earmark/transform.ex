defmodule Earmark.Transform do

  @moduledoc """
  Public Interface to functions operating on the AST
  exposed by `Earmark.as_ast`
  """

  @doc """
  Takes an ast, and optional options (I love this pun), which can be
  a map or keyword list of which the following keys will be used:

  - `smarty_pants:` `boolean`
  - `initial_indent:` `number`
  - `indent:` `number`


  Right now only transformation to HTML is supported.
  """
  def transform(ast, options \\ %{initial_indent: 0, indent: 2})
  def transform(ast, options) when is_list(options) do
    transform(ast, options|>Enum.into(%{initial_indent: 0, indent: 2}))
  end
  def transform(ast, options) do
    to_html(ast, [], options) |> IO.iodata_to_binary
  end


  defp to_html(ast, result, options)
  defp to_html(elements, result, _options) do
    result
  end

end
