defmodule Earmark.Cli.Args do

  alias Earmark.Options

  @moduledoc ~S"""
  parse args and return normalized results for processing by the CLI and the mix task
  """

  @doc false
  def parse_args(argv, switches, aliases) do

    case OptionParser.parse(argv, strict: switches, aliases: aliases) do
      { _, _, [_|_]=errors} -> {:error, _format_errors(errors)}
      { [ {:help, true} ], _, _ } -> :help
      { [ {:version, true} ], _, _ } -> :version
      { options, [ file ],  _ }  -> Map.put(Options.make_options!(options), :file, file)
      { options, [ ],           _ }  -> Options.make_options!(options)
    end
  end

  defp _format_errors(errors) do
    "Illegal options #{errors |> Enum.map(fn {option, _} -> option end) |> Enum.join(", ")}"
  end
end
