defmodule Support.Helpers do
  alias Earmark.Options

  ###############
  # Helpers.... #
  ###############

  def as_ast(markdown, options \\ []) do
    Earmark.Parser.as_ast(markdown, Options.make_options!(options))
  end

  def as_html(markdown, options \\ []) do
    Earmark.as_html(markdown, Options.make_options!(options))
  end

  def as_html!(markdown, options \\ []) do
    Earmark.as_html!(markdown, Options.make_options!(options))
  end
end

# SPDX-License-Identifier: Apache-2.0
