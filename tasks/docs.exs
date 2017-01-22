defmodule Mix.Tasks.Docs do
  use Mix.Task

  @shortdoc "Build docs with globally installed ex_doc to avoid conflicts"

  @moduledoc """

    ex_doc uses earmark. This means we can't have a dependency from
    earmark back to ex_doc, as this would be circular.

    Instead, we run ex_doc from the command line.
    
    ## Prerequisite
    
    ### Install `ex_doc` as an escript on your system ( Elixir >= 1.4 needed)

        mix escript.install hex ex_doc

    N.B. Launch the above command form anywhere else than your
    `Earmark` root directory.

  """

  def run(_) do
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


