    defmodule Earmark.Mixfile do
  use Mix.Project

  @version "1.4.35"

  @url "https://github.com/pragdave/earmark"


  @deps [
    {:earmark_parser, "~> 1.4.30" },
    # {:earmark_parser, path: "../earmark_parser"},
    {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
    {:benchfella, "~> 0.3.0", only: [:dev]},
    {:earmark_ast_dsl, "~> 0.3.6", only: [:dev, :test]},
    {:excoveralls, "~> 0.14.4", only: [:test]},
    # {:extractly, "~> 0.5.0", git: "https://github.com/RobertDober/extractly.git", tag: "v0.5.0-pre1", only: [:dev]},
    {:extractly, "~> 0.5.3", only: [:dev]},
    {:floki, "~> 0.21", only: [:dev, :test]},
    {:traverse, "~> 1.0.1", only: [:dev, :test]}
  ]

  @description """
  Earmark is a pure-Elixir Markdown converter.

  It is intended to be used as a library (just call Earmark.as_html),
  but can also be used as a command-line tool (run mix escript.build
  first).

  Output generation is pluggable.
  """

  ############################################################

  def project do
    [
      app: :earmark,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      escript: escript_config(),
      deps: @deps,
      description: @description,
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls],
      aliases: [docs: &build_docs/1]
    ]
  end

  def application do
    [
      extra_applications: [:eex],
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "dev"]
  defp elixirc_paths(:dev), do: ["lib", "lib1", "bench", "dev"]
  defp elixirc_paths(_), do: ["lib", "lib1"]

  defp escript_config do
    [main_module: Earmark.Cli]
  end

  defp package do
    [
      files: [
        "lib",
        "lib1",
        "mix.exs",
        "README.md"
      ],
      maintainers: [
        "Robert Dober <robert.dober@gmail.com>",
        "Dave Thomas <dave@pragdave.me>"
      ],
      licenses: [
        "Apache-2.0"
      ],
      links: %{
        "GitHub" => "https://github.com/pragdave/earmark"
      }
    ]
  end


  @prerequisites """
  run `mix escript.install hex ex_doc` and adjust `PATH` accordingly
  """
  defp build_docs(_) do
    Mix.Task.run("compile")
    ex_doc = Path.join(Mix.path_for(:escripts), "ex_doc")
    Mix.shell().info("Using escript: #{ex_doc} to build the docs")

    unless File.exists?(ex_doc) do
      raise "cannot build docs because escript for ex_doc is not installed, make sure to \n#{@prerequisites}"
    end

    args = ["Earmark", @version, Mix.Project.compile_path()]
    opts = ~w[--main Earmark --source-ref v#{@version} --source-url #{@url}]

    Mix.shell().info("Running: #{ex_doc} #{inspect(args ++ opts)}")
    System.cmd(ex_doc, args ++ opts)
    Mix.shell().info("Docs built successfully")
  end
end

# SPDX-License-Identifier: Apache-2.0
