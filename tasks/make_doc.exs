defmodule Mix.Tasks.MakeDoc do
  use Mix.Task

  @shortdoc "Build docs with globally installed ex_doc to avoid conflicts"

  @moduledoc """
    We are using `ex_doc` not as a dependency of the application, but as an installed escript
    to create the docs for `Earmark` thusly avoiding circular dependency issues.
    
    ## Prerequisite
    
    ### Install `ex_doc` as an escript on your system ( Elixir >= 1.4 needed)

        mix escript.install hex ex_doc

    N.B. Launch the above command form anywhere else than your `Earmark` root directory.

  """

  def run([]) do
    ex_doc = "#{System.get_env |> Map.get("HOME")}/.mix/escripts/ex_doc"
    System.cmd("rm", ~w( -rf doc ))
    System.cmd(ex_doc,
      ~w( Earmark #{current_version()} _build/dev/lib/earmark/ebin -m Earmark 
          -o doc -p https://github/pragdave/earmark.html -f html -n -n https://hexdocs.pm/earmark/master ))
  end

  defp current_version do
    Earmark.Mixfile.project() |> Keyword.get(:version)
  end
end


