defmodule Mix.Tasks.Readme do
  use Mix.Task

  @shortdoc "Build README.md by including module docs"

  @moduledoc """
  Imagine a README.md that contains

      # Overview

      <!-- moduledoc: Earmark -->

      # Typical calling sequence

      <!-- doc: Earmark.to_html -->

  Run this task, and the README will be updated with the appropriate
  documentation. Markers are also added, so running it again
  will update the doc in place.
  """

  def run([]) do
    Mix.Task.run "compile", []
    File.read!("README.md")
    |> remove_old_doc
    |> add_updated_doc
    |> make_toc
    |> write_back
  end

  @new_doc ~R/(\s* <!-- \s+ (module)?doc: \s* (\S+?) \s+ -->).*\n/x

  @existing_doc ~R/
     (?:^|\n+)(\s* <!-- \s+ (module)?doc: \s* (\S+?) \s+ -->).*\n
     (?: .*?\n )+?
     \s* <!-- \s end(?:module)?doc: \s+ \3 \s+ --> \s*?
  /x

  defp remove_old_doc(readme) do
    Regex.replace(@existing_doc, readme, fn (_, hdr, _, _) ->
        hdr
    end)
  end

  defp add_updated_doc(readme) do
    Regex.replace(@new_doc, readme, fn (_, hdr, type, name) ->
      "\n" <> hdr <> "\n" <>
      doc_for(type, name) <>
      Regex.replace(~r/!-- /, hdr, "!-- end") <> "\n"
    end)
  end

  defp doc_for("module", name) do
    module = String.to_atom("Elixir." <> name)

    docs = case Code.ensure_loaded(module) do
      {:module, _} ->
        if function_exported?(module, :__info__, 1) do
          case Code.get_docs(module, :moduledoc) do
            {_, docs} when is_binary(docs) ->
              docs
            _ -> nil
          end
        else
          nil
        end
      _ -> nil
    end

    docs # || "No module documentation available for #{name}\n"
  end

  defp doc_for("", name) do
    names = String.split(name, ".")
    [ func | modules ] = Enum.reverse(names)
    module = Enum.reverse(modules) |> Enum.join(".")
    module = String.to_atom("Elixir." <> module)
    func   = String.to_atom(func)

    markdown = case Code.ensure_loaded(module) do
      {:module, _} ->
        if function_exported?(module, :__info__, 1) do
          docs = Code.get_docs(module, :docs)
          Enum.find_value(docs, fn ({{fun, _}, _line, _kind, _args, doc}) ->
            fun == func && doc
          end)
        else
          nil
        end
      _ -> nil
    end

    markdown || "No function documentation available for #{name}\n"
  end

  @existing_toc ~R{
    (?:^|\n)( <!-- \s+ make \s TOC \s+ --> )
    (?: .*?\n )+?
    ( <!-- \s+ endmake \s TOC \s+ --> \s* \n )
  }x
  defp remove_toc(readme) do
    Regex.replace(@existing_toc, readme, fn _, begin_marker, end_marker ->
      [
        "",
        begin_marker,
        end_marker
      ] |> Enum.join("\n")
    end) 
  end
  defp replace_toc(readme, new_toc) do
    Regex.replace(@existing_toc, readme, fn _, begin_marker, end_marker ->
      [
        "",
        begin_marker,
        "## Table Of Contents\n",
        Enum.intersperse(new_toc, "\n"),
        end_marker
      ] |> Enum.join("\n")
    end) 
  end

  @h2_line_rgx ~r{\A\##\s+}
  defp make_toc(readme) do
    readme = readme |> remove_toc()
    h2s = readme |> String.split("\n") |> extract_h2s
    readme |> replace_toc(h2s)
  end

  defp extract_h2s(lines) do
    for line <- lines, Regex.match?(@h2_line_rgx, line), do: make_h2_link(line)
  end

  defp make_h2_anchor(title) do
    title |> String.downcase() |> String.replace(~r{\s+}, "-")
  end

  defp make_h2_link(h2_line) do
    with title <- String.replace(h2_line, @h2_line_rgx, "") |> String.trim() do
      "* [#{title}](##{make_h2_anchor(title)})"
    end
  end

  defp write_back(readme) do
    IO.puts :stderr,
      (case File.write("README.md", readme) do
        :ok -> "README.md updated"
        {:error, reason} ->
           "README.md: #{:file.format_error(reason)}"
      end)
  end
end


# SPDX-License-Identifier: Apache-2.0
