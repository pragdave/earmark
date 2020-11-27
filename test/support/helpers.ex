defmodule Support.Helpers do

  alias Earmark.Context

  ###############
  # Helpers.... #
  ###############

  def context do
    %Earmark.Context{}
  end

  def as_ast(markdown, options \\ []) do
    EarmarkParser.as_ast(markdown, struct(Earmark.Options, options))
  end

  def as_html(markdown, options \\ []) do
    Earmark.as_html(markdown, struct(Earmark.Options, options))
  end

  def as_html!(markdown, options \\ []) do
    Earmark.as_html!(markdown, struct(Earmark.Options, options))
  end

  def gfm_context do
    Context.update_context(context())
  end

end

# SPDX-License-Identifier: Apache-2.0
