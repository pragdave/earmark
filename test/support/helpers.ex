defmodule Support.Helpers do

  alias Earmark.Options

  ###############
  # Helpers.... #
  ###############


  def as_ast(markdown, options \\ []) do
    EarmarkParser.as_ast(markdown, Options.make_options!(options))
  end

  def as_html(markdown, options \\ []) do
    Earmark.as_html(markdown, Options.make_options!(options)) |> remove_deprecations()
  end

  def as_html!(markdown, options \\ []) do
    Earmark.as_html!(markdown, Options.make_options!(options))
  end

  def remove_deprecations({status, html, messages}) do
    messages1 = Enum.filter(messages, fn {level, _, _} -> level != :deprecated end)
    {status, html, messages1}
  end

  def remove_deprecation_messages(output, file \\ "<no file>") do
    deprecation_message =
      ~r[#{file}:0: deprecated: .*\n]

    Regex.replace(deprecation_message, output, "")
  end

end
# SPDX-License-Identifier: Apache-2.0
