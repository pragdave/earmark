defmodule Earmark2.Parser do

  alias Earmark.Options
  alias Earmark2.Parser.Ast, as: A

  import Earmark2.Scanner, only: [scan_lines: 1]


  @moduledoc """
  We scan tokens per line and then unify them with line numbers.
  After which we call parse to create an AST representation of
  the markdown document
  """


  @doc """
  Parses a document into an AST (Abstract Syntax Tree) representation
  of Markdown

      iex(2)> %{nodes: nodes} = parse_document("")
      ...(2)> nodes
      []
  """
  def parse_document(document, options \\ %Options{})
  def parse_document(document, options) when is_binary(document) do
    document |> String.split(~r{\r?\n}) |> scan_lines() |> parse_document(options)
  end
  def parse_document(tokens, _options) do
    parse(tokens, :init, [], [])
  end


  @doc false
  def parse(tokens, state, ast, errors)
  def parse([], :end, ast, errors), do: {ast |> A.close_ast, errors}
  def parse([], state, ast, errors), do: {ast |> A.close_ast, [{:error,0, "unexpected EOI in state #{state}"} | Enum.reverse(errors)]}
  def parse(tokens, :init, ast, errors), do: parse_init(tokens, ast, errors)


  defp parse_init([], ast, errors), do: parse([], :end, ast, errors)
  defp parse_init([{:st_blank, _, _}|rest], ast, errors), do: parse_init(rest, ast, errors)
  defp parse_init(tokens = [{:text, _, _}|_],ast, errors), do: parse_para(tokens, [{:para, [], []}|ast], errors)

  defp parse_para([{:text, text, _}|rest], ast, errors) do
    parse_para(rest, A.add_text(text, ast), errors)
  end
  defp parse_para([], ast, errors), do: parse([], :end, ast, errors)
end
