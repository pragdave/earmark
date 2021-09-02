defmodule Earmark.Cli.Implementation do

  alias Earmark.Options
  alias Earmark.SysInterface

  @moduledoc """
  Functional (with the exception of reading input files with `Earmark.File`) interface to the CLI
  returning the device and the string to be output.
  """

  @doc """
  allows functional access to the CLI API, does everything `Earmark.Cli.main` does without outputting the result

  Returns a tuple of the device to write to (`:stdio|:stderr`) and the content to be written

  Example: Bad file

      iex(0)> run(["no-such--file--ayK7k"])
      {:stderr, "Cannot open no-such--file--ayK7k, reason: enoent"}

  """
  def run(argv) do
    argv
    |> parse_args()
    |> process()
  end

  @args """
  usage:

     earmark --help
     earmark --version
     earmark [ options... <file> ]

  convert file from Markdown to HTML.

     where options can be any of:
       --code-class-prefix <a prefix>
       --gfm
       --smartypants
       --pedantic
       --pure-links
       --breaks
       --timeout <timeout in ms>
       --wikilinks

  """

  @cli_options [:code_class_prefix, :gfm, :smartypants, :pedantic, :pure_links, :breaks, :timeout, :wikilinks]

  defp parse_args(argv) do
    switches = [
      help: :boolean,
      version: :boolean
      ]
    aliases = [
      h: :help,
      v: :version
    ]

    case OptionParser.parse(argv, switches: switches, aliases: aliases) do
      { [ {switch, true } ],  _, _ } -> switch
      { options, [ filename ],  _ }  -> {open_file(filename), filename, options}
      { options, [ ],           _ }  -> {{:ok, :stdio}, "<no file>", options}
      _                              -> :help
    end
  end

  defp process(flag_or_triple)
  defp process(:help) do
    {:stderr, IO.chardata_to_string([@args, option_related_help()])}
  end
  defp process(:version) do
    {:stdio, Earmark.version}
  end
  defp process({{:error, reason}, filename, _}) do
    {:stderr, "Cannot open #{filename}, reason: #{reason}"}
  end
  defp process({{:ok, io_device}, filename, options}) do
    options_ = [{:file, filename} | options] |> Options.make_options!

    content = SysInterface.sys_interface.readlines(io_device) |> Enum.to_list
    {:stdio, Earmark.as_html!(content, options_)}
  end

  defp open_file(filename), do: File.open(filename, [:utf8])

  defp option_related_help do
    @cli_options
    |> Enum.map(&specific_option_help/1)
    |> Enum.join("\n")
  end

  defp specific_option_help(option) do
    "      --#{unixize_option(option)} defaults to #{inspect(Map.get(%Earmark.Options{}, option))}"
  end

  defp unixize_option(option) do
    "#{option}"
    |> String.replace("_", "-")
  end

end

# SPDX-License-Identifier: Apache-2.0
