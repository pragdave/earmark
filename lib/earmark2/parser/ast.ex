defmodule Earmark2.Parser.Ast do
  alias Earmark.Options

  defstruct nodes: [],
            options: %Options{},
            errors: []
  

  def illegal_end(%__MODULE__{errors: errors} = ast, state) do
    %{reverse_nodes(ast) | errors: [{:error, "illegal end of input in state #{state}", 0, 0} | errors]}
  end
  def push_node(%__MODULE__{nodes: nodes} = ast, node), do: %{ast | nodes: [node|nodes]}
  def reverse_nodes(%__MODULE__{nodes: nodes} = ast), do: %{ast | nodes: Enum.reverse(nodes)}          

end
