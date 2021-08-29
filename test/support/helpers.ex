defmodule Support.Helpers do

  alias Earmark.Context
  alias Earmark.Options

  ###############
  # Helpers.... #
  ###############

  def context do
    %Earmark.Context{}
  end

  def as_ast(markdown, options \\ []) do
    EarmarkParser.as_ast(markdown, Options.make_options!(options))
  end

  def as_html(markdown, options \\ []) do
    Earmark.as_html(markdown, Options.make_options!(options))
  end

  def as_html!(markdown, options \\ []) do
    Earmark.as_html!(markdown, Options.make_options!(options))
  end

  def gfm_context do
    Context.update_context(context())
  end

end

# SPDX-License-Identifier: Apache-2.0
