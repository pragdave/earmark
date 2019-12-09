defmodule Earmark.Transform do

  use Earmark.Types

  alias Earmark.Options

  @type transformer_t :: ((list(), any()) -> binary())
  @moduledoc """
  **EXPERIMENTAL**
  But well tested, just expect API changes in the 1.4 branch.
  """

  @doc """
  AST transformation, frontend.
  This is a convenience method.

  Takes markdown, a transformer and options.

  As a matter of fact this can be wrapped around a transformer function that accepts an ast and options and will
  feed the parsed markdown into the transfomer function iff the parser did not issue any errors.

  E.g

        iex(0)> ~s{a} |> transform_markdown(fn ast, _ -> Enum.count(ast) end)
        {:ok, 1, []}

  However if parsing encounters errors, the transformer is not invoked and the parser's result is returned

        iex(1)> ~s{`a} |> transform_markdown(nil)
        {:error, [{\"p\", [], [\"`a\"]}], [{:warning, 1, \"Closing unclosed backquotes ` at end of input\"}]}
  """
  @spec transform_markdown( String.t, transformer_t(), any() ) :: {atom, any(), list}
  def transform_markdown(markdown, transformer, options \\ %Options{}) do
    with {:ok, ast, messages} <- Earmark.as_ast(markdown, options) do
      {:ok, transformer.(ast, options), messages}
    end
  end


end
