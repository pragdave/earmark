defmodule Earmark.Cli.Implementation do


  alias Earmark.Options
  alias Earmark.SysInterface

  @moduledoc """
  Functional (with the exception of reading input files with `Earmark.File`) interface to the CLI
  returning the device and the string to be output.
  """

  @doc ~S"""
  allows functional access to the CLI API, does everything `Earmark.Cli.main` does without outputting the result

  Returns a tuple of the device to write to (`:stdio|:stderr`) and the content to be written

  Example: Bad file

      iex(0)> run(["no-such--file--ayK7k"])
      {:stderr, "Cannot open no-such--file--ayK7k, reason: enoent"}

  Example: Good file

      iex(1)> {:stdio, html} = run(["test/fixtures/short1.md"])
      ...(1)> html
      "<h1>\nHeadline1</h1>\n<hr class=\"thin\" />\n<h2>\nHeadline2</h2>\n"

  Example: Using EEx

      iex(2)> {:stdio, html} = run(["--eex", "--gfm", "--code-class-prefix", "alpha", "--timeout", "12000", "test/fixtures/short2.md.eex"])
      ...(2)> html
      "<h1>\nShort2</h1>\n<p>\n<em>Short3</em></p>\n<!-- SPDX-License-Identifier: Apache-2.0 -->\n"


  Example: Using an EEx template first

      iex(3)> run(["--template", "test/fixtures/eex_first.html.eex"])
      {:stdio, "<html>\n  <h1>\nShort2</h1>\n<p>\n<em>Short3</em></p>\n<!-- SPDX-License-Identifier: Apache-2.0 -->\n\n</html>\n"}

  """

  def run(argv) do
    argv
    |> _parse_args()
    |> _process()
  end

  @args """
  usage:

     earmark --help
     earmark --version
     earmark [ options... <file> ]

  convert file from Markdown to HTML.

     where options can be any of:
       --breaks
       --code-class-prefix <a prefix>
       --eex
       --escape
       --gfm
       --smartypants
       --pedantic
       --pure-links
       --breaks
       --template
       --timeout <timeout in ms>
       --wikilinks

  """

  @cli_options ~W[
    breaks
    code_class_prefix
    eex escape
    gfm
    pedantic pure_links
    smartypants
    template timeout
    wikilinks
  ]

  defp _parse_args(argv) do
    switches = [
      breaks: :boolean,
      code_class_prefix: :string,
      eex: :boolean,
      escape: :boolean,
      gfm: :boolean,
      help: :boolean,
      pedantic: :boolean,
      pure_links: :boolean,
      template: :boolean,
      timeout: :integer,
      version: :boolean,
      wikiklinks: :boolean
      ]
    aliases = [
      h: :help,
      v: :version
    ]

    case OptionParser.parse(argv, switches: switches, aliases: aliases) do
      { [ {:help, true} ], _, _ } -> :help
      { [ {:version, true} ], _, _ } -> :version
      { options, [ file ],  _ }  -> Map.put(Options.make_options!(options), :file, file)
      { options, [ ],           _ }  -> Options.make_options!(options)
    end
  end

  defp _process(flag_or_options)
  defp _process(:help) do
    {:stderr, IO.chardata_to_string([@args, _option_related_help()])}
  end
  defp _process(:version) do
    {:stdio, Earmark.version}
  end
  defp _process(%Options{file: nil}=options), do: _process_input({:ok, :stdio}, options)
  defp _process(%Options{file: filename}=options), do: _process_input(_open_file(filename), options)

  defp _process_input(device_tuple, options)
  defp _process_input({:error, reason}, options) do
    {:stderr, "Cannot open #{options.file}, reason: #{reason}"}
  end
  defp _process_input({:ok, io_device}, %Options{template: true}) do
    {:stdio, EEx.eval_string(SysInterface.sys_interface.readlines(io_device) |> Enum.to_list |> IO.chardata_to_string)}
  end
  defp _process_input({:ok, io_device}, options) do
    content = _get_content(io_device, options)
    {:stdio, Earmark.as_html!(content, options)}
  end

  defp _get_content(io_device, options)
  defp _get_content(io_device, %Options{eex: false}), do: SysInterface.sys_interface.readlines(io_device) |> Enum.to_list
  defp _get_content(io_device, %Options{file: nil}), do: SysInterface.sys_interface.readlines(io_device) |> Enum.to_list |> IO.chardata_to_string |> EEx.eval_string
  defp _get_content(_io_device, %Options{file: filename}), do: EEx.eval_file(filename)

  defp _open_file(filename), do: File.open(filename, [:utf8])

  defp _option_related_help do
    @cli_options
    |> Enum.map(&_specific_option_help/1)
    |> Enum.join("\n")
  end

  defp _specific_option_help(option) do
    "      --#{_unixize_option(option)} defaults to #{inspect(Map.get(%Earmark.Options{}, option))}"
  end

  defp _unixize_option(option) do
    "#{option}"
    |> String.replace("_", "-")
  end

end
# SPDX-License-Identifier: Apache-2.0
