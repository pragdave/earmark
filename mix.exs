Code.eval_file "tasks/readme.exs"

defmodule Earmark.Mixfile do
  use Mix.Project

  def project do
    [
      app:         :earmark,
      version:     "0.1.1",
      elixir:      "~> 0.14.2",
      escript:     escript_config,
      deps:        deps,
      description: description,
      package:     package,
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    []
  end

  defp description do
    """
    Earmark is a pure-Elixir Markdown converter. 

    It is intended to be used as a library (just call Earmark.to_html),
    but can also be used as a command-line tool (just run mix escript.build
    first).

    In theory, the output generation is pluggable.
    """
  end

  defp package do
    [
      files:        [ "lib", "priv", "mix.exs", "README.md" ],
      contributors: [ "Dave Thomas <dave@pragprog.org>"],
      licenses:     [ "Same as Elixir" ],
      links:        %{
                       "GitHub" => "https://github.com/pragdave/earmark",
                    }
    ]
  end

  defp escript_config do
    [ main_module: Earmark.CLI ]
  end
end
