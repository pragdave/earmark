defmodule Earmark.Mixfile do
  use Mix.Project

  def project do
    [app: :earmark,
     version: "0.0.1",
     elixir: "~> 0.14",
     escript: escript_config,
     deps: deps]
  end

  def application do
    [applications: []]
  end

  defp deps do
    []
  end

  defp escript_config do
    [ main_module: Earmark.CLI ]
  end

end
