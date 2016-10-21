defmodule Earmark.CLI do

  def main(argv) do
    argv 
    |> parse_args 
    |> process
  end

  @args """
  usage:

     earmark [ <file> ]

  convert file from Markdown to HTML.
  """

  defp parse_args(argv) do
    switches = [
      help: :boolean,
      version: :boolean
      ]
    aliases = [
      h: :help,
      v: :version
    ]

    parse = OptionParser.parse(argv, switches: switches, aliases: aliases)
    case  parse  do
      { [ {switch, true } ],  _, _ } -> switch
      { options, [ filename ],  _ }  -> {open_file(filename), options}
      { options, [ ],           _ }  -> {:stdio, options}
      _                              -> :help
    end
  end


  defp process(:help) do
    IO.puts(:stderr, @args)
    exit(2)
  end

  defp process(:version) do
    {:ok, version} = :application.get_key(:earmark, :vsn)
    IO.puts( version )
  end

  defp process({io_device, options}) do
    options = options 
      |> booleanify()
      |> Enum.into(%Earmark.Options{})
    content = IO.stream(io_device, :line) |> Enum.to_list
    Earmark.to_html(content, options)
    |> IO.puts
  end



  defp booleanify( keywords ), do: Enum.map(keywords, &booleanify_option/1)
  defp booleanify_option({k, v}) do
    {k, 
     case Map.get %Earmark.Options{}, k, :does_not_exist do
        true  -> if v == "false", do: false, else: true
        false -> if v == "false", do: false, else: true
        :does_not_exist ->
          IO.puts( :stderr, "ignoring unsupported option #{inspect k}")
          v
        _     -> v
      end
    }
  end

  defp open_file(filename), do: io_device(File.open(filename, [:utf8]), filename)

  defp io_device({:ok, io_device}, _), do: io_device
  defp io_device({:error, reason}, filename) do
    IO.puts(:stderr, "#{filename}: #{:file.format_error(reason)}")
    exit(1)
  end


end
