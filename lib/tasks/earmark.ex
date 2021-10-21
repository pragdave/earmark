defmodule Mix.Tasks.Earmark do
  use Mix.Task

  alias Earmark.Options
  alias Earmark.SysInterface

  import Earmark.Cli.Args, only: [parse_args: 3]

  @moduledoc ~S"""
  """

  @switches [
    breaks: :boolean,
    code_class_prefix: :string,
    escape: :boolean,
    gfm: :boolean,
    help: :boolean,
    inner_html: :boolean,
    pedantic: :boolean,
    pure_links: :boolean,
    timeout: :integer,
    version: :boolean,
    wikiklinks: :boolean
  ]

  @aliases [
    h: :help,
    v: :version
  ]

  @usage """
  """

  @impl true
  def run(args) do
    args
    |> parse_args(@switches, @aliases)
    |> _process()
    |> _output()
  end

  defp _output(tuple_or_ignore)
  defp _output({device, message}), do: IO.puts(device, message)
  defp _output(_), do: nil

  @correct_eex_rgx ~r{\. eex \z}x

  defp _process(flag_errors_or_options)
  defp _process({:error, errors}) do
    {:stderr, errors}
  end
  defp _process(:help) do
    {:stderr, @usage}
  end
  defp _process(:version) do
    {:stdio, Earmark.version}
  end
  defp _process(%Options{file: nil}=options), do: {:stderr, "Missing input file"}
  defp _process(%Options{file: filename}=options) do
    cond do
      Regex.match?(@correct_eex_rgx, filename) ->
        filename
        |> SysInterface.sys_interface.readlines
        |> _process_input(Regex.replace(@correct_eex_rgx, filename, ""), options)
      true ->
        {:stderr, "Input file needs to be an eex template, not #{filename}"}
    end
  end

  defp _process_input(device_tuple, out_filename, options)
  defp _process_input({:error, reason}, _filename, options) do
    {:stderr, "Cannot open #{options.file}, reason: #{reason}"}
  end
  defp _process_input(io_stream, filename, options) do
    io_stream
    |> Enum.to_list
    |> IO.chardata_to_string
    |> EEx.eval_string(earmark: Earmark, options: options)
    |> _write!(filename)
  end

  defp _write!(content, filename), do: File.write!(filename, content)
end
#  SPDX-License-Identifier: Apache-2.0
