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
  def as_ast(input, options \\ %Earmark.Options{})
  def as_ast(input, options) when is_list(options)  do
    EarmarkParser.as_ast(input, Keyword.delete(options, :smartypants))
  end
  def as_ast(input, options) when is_map(options)  do
    EarmarkParser.as_ast(input, Map.delete(options, :smartypants))
  end

end
#  SPDX-License-Identifier: Apache-2.0
