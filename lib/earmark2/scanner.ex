defmodule Earmark2.Scanner do

  import Earmark.Helpers.LeexHelpers, only: [tokenize: 2]

  @moduledoc """
  An interface to the leex lexer `src/token_lexer.xrl`
  """

  @doc """
  A single line is feed to the `src/token_lexer.xrl` and
  reconverted into an Elixir tuple
  """
  def scan(line) do
    tokenize(line, with: :token_lexer) 
  end
  
end
