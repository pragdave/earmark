defmodule StmdTest do
  defmodule Spec do
    def file, do: "test/spec.txt"
  end

  if File.exists?(Spec.file) do

    defmodule StmdTest.Reader do
      def tests do
        File.open!(Spec.file)
        |> IO.stream(:line)
        |> Enum.reduce({:scanning, []}, &split_into_tests/2)
        |> case(do: ({:scanning, result} -> result))
      end

      ############
      # Scanning #
      ############

      defp split_into_tests(".\n", {:scanning, result}) do
        { :collecting_markdown, [ %{ md: [] } | result ] }
      end

      defp split_into_tests(_other, {:scanning, result}) do
        { :scanning, result }
      end

      #######################
      # Collecting Markdown #
      #######################

      defp split_into_tests(".\n", {:collecting_markdown, [ %{ md: md } | result]}) do
        { :collecting_html, [ %{ md: md, html: [] } | result ] }
      end

      defp split_into_tests(line, {:collecting_markdown, [ %{ md: md } | result ]}) do
        { :collecting_markdown, [ %{ md: [line|md] } | result ] }
      end

      ###################
      # Collecting HTML #
      ###################

      defp split_into_tests(".\n", {:collecting_html, result}) do
        { :scanning, result }
      end

      defp split_into_tests(line, {:collecting_html, [ %{ md: md, html: html} | result]}) do
        { :collecting_html, [ %{ md: md, html: [line|html] } | result] }
      end

    end

    use ExUnit.Case

    for %{ md: md, html: html } <- StmdTest.Reader.tests do
      @md   Enum.join(Enum.reverse(md))
      @html Enum.join(Enum.reverse(html))
      test "\n--- === ---\n" <> @md <> "--- === ---\n" do
        result = Earmark.to_html(@md)
        assert result == @html
      end
    end

  else

    IO.puts "Skipping spec tests—spec.txt not found"
    IO.puts "(hint: ln -s stmd/spec.txt to spec.txt)"

  end
end
