defmodule Earmark2.Parser.Ast do
  alias Earmark.Options

  defstruct nodes: [],
            options: %Options{},
            errors: []


  def add_text text, ast do
    with [{tag, atts, content}|rest] <- ast do
      [{tag, atts, [text|content]}|rest]
    end
  end

  def close_ast(ast)
  def close_ast([]), do: []
  def close_ast([current|rest]), do:
    # ast |> Enum.reject(&Enum.empty?/1) |> Enum.reverse
    [close_current_node(current) | rest] |> Enum.reverse

  def close_current_node({tag, atts, content}), do: {tag, atts, content |> Enum.reverse}


  def illegal_end(%__MODULE__{errors: errors} = ast, state) do
    %{reverse_nodes(ast) | errors: [{:error, "illegal end of input in state #{state}", 0, 0} | errors]}
  end
  def push_node(%__MODULE__{nodes: nodes} = ast, node), do: %{ast | nodes: [node|nodes]}
  def reverse_nodes(%__MODULE__{nodes: nodes} = ast), do: %{ast | nodes: Enum.reverse(nodes)}

end
