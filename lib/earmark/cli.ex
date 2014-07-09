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
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
                                     aliases:  [ h:    :help   ])
    case  parse  do

    { [ help: true ],  _,  _ } -> :help
    { _, [ filename ], _     } -> open_file(filename)
    { _, [ ],          _ }     -> :stdio
    _                          -> :help
    end
  end


  defp process(:help) do
    IO.puts(:stderr, @args)
    exit(2)
  end

  defp process(io_device) do
    content = IO.stream(io_device, :line) |> Enum.to_list
    Earmark.to_html(content, %Earmark.Options{})
    |> IO.puts
  end



  defp open_file(filename), do: io_device(File.open(filename, [:utf8]), filename)

  defp io_device({:ok, io_device}, _), do: io_device
  defp io_device({:error, reason}, filename) do
    IO.puts(:stderr, "#{filename}: #{:file.format_error(reason)}")
    exit(1)
  end


end