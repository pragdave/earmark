defmodule Earmark.Types do

  @moduledoc false

  defmacro __using__(_options \\ []) do
    quote do
      @type ast    :: list(ast_node)
      @type ast_attribute :: {String.t, String.t}
      @type ast_attributes :: list(ast_attribute)
      @type ast_node :: String.t | ast_triple | ast_quadruple
      @type ast_quadruple :: { String.t, ast_attributes, ast, any }
      @type ast_triple :: { String.t, ast_attributes, ast }

      @type token  :: {atom, String.t}
      @type tokens :: list(token)
      @type numbered_line :: %{required(:line) => String.t, required(:lnb) => number, optional(:inside_code) => String.t}
      @type message_type :: :warning | :error
      @type message :: {message_type, number, String.t}
      @type maybe(t) :: t | nil
      @type inline_code_continuation :: {nil | String.t, number}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
