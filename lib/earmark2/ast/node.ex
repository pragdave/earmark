defmodule Earmark2.Ast.Node do
  defstruct tag: :text,
            atts: %{},
            body: []
end
