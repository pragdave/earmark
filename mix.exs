Code.eval_file "tasks/readme.exs"

defmodule Earmark.Mixfile do
  use Mix.Project

  def project do
    [
      app:          :earmark,
      version:      "0.2.1",
      elixir:       ">= 1.0.0",
      elixirc_paths: elixirc_paths(Mix.env),
      escript:       escript_config,
      deps:          deps,
      description:   description,
      package:       package,
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:poison, "~> 1.5", only: [:dev, :test]},
     {:kwfuns, "~> 0.0", only: :test}]
  end

  defp description do
    """
    Earmark is a pure-Elixir Markdown converter.

    It is intended to be used as a library (just call Earmark.to_html),
    but can also be used as a command-line tool (just run mix escript.build
    first).

    Output generation is pluggable.
    """
  end

  defp package do
    [
      files:       [ "lib", "tasks", "mix.exs", "README.md" ],
      maintainers: [ "Dave Thomas <dave@pragprog.org>"],
      licenses:    [ "Same as Elixir" ],
      links:       %{
                       "GitHub" => "https://github.com/pragdave/earmark",
                   }
    ]
  end

  defp escript_config do
    [ main_module: Earmark.CLI ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
