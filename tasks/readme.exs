defmodule Mix.Tasks.Readme do
  use Mix.Task

  @shortdoc "Build README.md from README.template by including module docs"

  @moduledoc """
  README.md is generated from README.template by expanding the following special
  lines, all triggered by the regex `~r{\A%\w+}` where:

  * `%toc` creates the Table Of Contents section

  * `%moduledoc module` inserts the corresponding moduledoc

  * `%functiondoc function` inserts the corresponding functiondoc

  As the `README.md` is now regenerated every time no markers are needed in the `README.md` anymore,
  however to be able to trace the origin of any part that needs to changed appropriate comments
  are inserted anyway.
  """

  def run([]) do
    Mix.Task.run "compile", []
    File.read!("README.template")
    |> String.split("\n")
    |> expand_docs([])
    |> extract_tocs({[], []})
    |> write_lines_to_readme_md()
  end


  defp expand_docs( lines, result )
  defp expand_docs( [], result ), do: result
  defp expand_docs( ["%toc" | rest], result), do: expand_docs(rest, ["%toc" | result])
  defp expand_docs( ["%" <> line | rest], result), do: expand_docs(rest, [add_doc(line) | result])
  defp expand_docs( [line | rest], result ), do: expand_docs(rest, [line | result])

  defp extract_tocs(lines, result)
  defp extract_tocs([], {lines, _}), do: lines
  defp extract_tocs([ hl2 = "## " <> title | before ], { body, tocs }),
    do: extract_tocs(before, { [hl2 | body], [make_toc_entry( title) | tocs] })
  defp extract_tocs([ "%toc" | before ], {body, tocs}),
    do: extract_tocs(before, { [make_toc_string(tocs) | body], [] })
  defp extract_tocs( [line | before], {body, tocs}),
    do: extract_tocs(before, {[line|body], tocs})

  defp add_doc(line) do
    [ "<!-- BEGIN inserted #{line} -->",
      line 
      |> String.split()
      |> doc_for(),
      "<!-- END inserted #{line} -->" ]
     |> Enum.join("\n")
  end

  defp doc_for(["moduledoc", name]) do
    module = String.to_atom("Elixir." <> name)

    docs = case Code.ensure_loaded(module) do
      {:module, _} ->
        if function_exported?(module, :__info__, 1) do
          {:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, _} = Code.fetch_docs(module)
          module_doc
          # case Code.get_docs(module, :moduledoc) do
          #   {_, docs} when is_binary(docs) ->
          #     docs
          #     _ -> nil
          # end
        else
          nil
        end
        _ -> nil
    end

    docs # || "No module documentation available for #{name}\n"
  end
  defp doc_for(["functiondoc", name]) do
    names = String.split(name, ".")
    [ func | modules ] = Enum.reverse(names)
    module = ["Elixir" | Enum.reverse(modules)] |> Enum.join(".") |> String.to_atom()
    [ function_name, arity ]  = String.split(func, "/")
    function_name = String.to_atom(function_name)
    {arity, _}    = Integer.parse(arity)

    markdown = case Code.ensure_loaded(module) do
      {:module, _} ->
        if function_exported?(module, :__info__, 1) do
          {:docs_v1, _, :elixir, _, _, _, docs} = Code.fetch_docs(module)
          Enum.find_value(docs, &find_function_doc(&1, function_name, arity))
        else
          nil
        end
        _ -> nil
    end

    markdown || "No function documentation available for #{name}\n"
  end

  defp find_function_doc(doctuple, function_name, arity) do
    case doctuple do
      {{:function, ^function_name, ^arity}, _anno, _sign, %{"en" => doc}, _metadata} -> doc
      _                                                                          -> nil
    end
  end

  defp make_h2_anchor(title), do: title |> String.downcase() |> String.replace(~r{\s+}, "-")

  defp make_toc_entry(title), do: "* [#{title}](##{make_h2_anchor(title)})"

  defp make_toc_string(tocs),
    do: 
      [ "<!-- BEGIN generated TOC -->",
        tocs |> Enum.join("\n"),
        "<!-- END generated TOC -->"
      ] |> Enum.join("\n")

  defp write_lines_to_readme_md(lines) do
    lines
    |> Enum.join("\n")
    |> write_string_to_readme_md()
  end

  defp write_string_to_readme_md(content) do
    IO.puts :stderr,
    (case File.write("README.md", content) do
      :ok -> "README.md regenerated"
      {:error, reason} ->
        "README.md: #{:file.format_error(reason)}"
    end)
  end
end

# SPDX-License-Identifier: Apache-2.0
