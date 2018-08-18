defmodule Earmark2.Parser do

  alias Earmark.Options
  alias Earmark2.Parser.Ast


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
  def parse_document(document, options \\ %Options{}) do
  end


  @doc false
  def parse(tokens, state, ast \\ %Ast{})
  def parse([], :end, ast), do: Ast.reverse_nodes(ast)
  def parse([], state, ast), do: Ast.illegal_end(ast, state)
  
  def parse(tokens, :init, ast) do
    Ast.push_node(ast, {:para, parse_para(tokens, ast, [])})
  end


  defp parse_para(tokens, ast, para)
  defp parse_para([{:verb, _, _, _}=verb|tokens], ast, para), do: parse_para(tokens, ast, [verb|para])
  defp parse_para([{:eol, _, _, _}|tokens], ast, para), do: parse_para(tokens, ast, para)
  defp parse_para([], _, para), do: para |> Enum.reverse



end
