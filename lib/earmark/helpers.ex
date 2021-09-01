defmodule Earmark.Helpers do

  @doc """
  `Regex.replace` with the arguments in the correct order
  """

  def replace(text, regex, replacement, options \\ []) do
    Regex.replace(regex, text, replacement, options)
  end
end

# SPDX-License-Identifier: Apache-2.0
