defmodule Earmark.EarmarkParserProxy do
  @moduledoc ~S"""
  This acts as a proxy to adapt to changes in `EarmarkParser`'s API

  If no changes are needed it can delegate `as_ast` to `EarmarkParser`

  If changes are needed they will be realised in this modules `as_ast`
  function.

  For that reason `EarmarkParser.as_ast/*` **SHALL NOT** be invoked
  anywhere else in this code base
  """

  @doc ~S"""
  An adapter to `EarmarkParser.as_ast/*`
  """
  def as_ast(input, options)
  def as_ast(input, options) when is_list(options)  do
    EarmarkParser.as_ast(input, options |> Keyword.delete(:smartypants) |> Keyword.delete(:messages))
  end
  def as_ast(input, options) when is_map(options)  do
    EarmarkParser.as_ast(input, options |> Map.delete(:smartypants) |> Map.delete(:messages))
  end

end
#  SPDX-License-Identifier: Apache-2.0
