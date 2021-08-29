defmodule Earmark.Options do
  use Earmark.Types

  # What we use to render
  defstruct renderer: Earmark.HtmlRenderer,
            # Inline style options
            gfm: true,
            gfm_tables: false,
            breaks: false,
            pedantic: false,
            smartypants: true,
            footnotes: false,
            footnote_offset: 1,
            wikilinks: false,
            escape: true,

            # additional prefies for class of code blocks
            code_class_prefix: nil,

            # Add possibility to specify a timeout for Task.await
            timeout: nil,

            # Internal—only override if you're brave
            do_smartypants: nil,

            # Very internal—the callback used to perform
            # parallel rendering. Set to &Enum.map/2
            # to keep processing in process and
            # serial
            mapper: &Earmark.pmap/2,
            mapper_with_timeout: &Earmark.pmap/3,

            # Filename and initial line number of the markdown block passed in
            # for meaningfull error messages
            file: "<no file>",
            line: 1,
            # [{:error|:warning, lnb, text},...]
            messages: [],
            pure_links: true,
            compact_output: false,
            ignore_strings: false,
            postprocessor: nil,
            registered_processors: []


  @type t :: %__MODULE__{
        breaks: boolean,
        code_class_prefix: maybe(String.t),
        footnotes: boolean,
        footnote_offset: number,
        gfm: boolean,
        pedantic: boolean,
        pure_links: boolean,
        smartypants: boolean,
        wikilinks: boolean,
        timeout: maybe(number),
        escape: boolean
  }

  @doc false
  # Only here we are aware of which mapper function to use!
  def get_mapper(options) do
    if options.timeout do
      &options.mapper_with_timeout.(&1, &2, options.timeout)
    else
      options.mapper
    end
  end

  def make_options(options)
  def make_options(options) when is_list(options) do
    legal_keys =
      __MODULE__
      |> struct()
      |> Map.keys
      |> MapSet.new

    given_keys =
      options
      |> Keyword.keys
      |> MapSet.new

    violators =
      MapSet.difference(given_keys, legal_keys)

    if MapSet.size(violators) == 0 do
      {:ok, struct(__MODULE__, options) |> _normalize()}
    else
      {:error, _format_errors(violators, options)}
    end
  end
  def make_options(options) when is_map(options) do
    options
    |> Enum.into([])
    |> make_options()
  end

  def make_options!(options) do
    case make_options(options) do
      {:ok, options_} -> options_
      {:error, errors} -> raise Earmark.Error, inspect(errors)
    end
  end

  @doc """
  A convenience constructor
  """
  def with_postprocessor(pp, rps \\ []), do: %__MODULE__{postprocessor: pp, registered_processors: rps}

  defp _format_error(violator, options) do
    {:warning, 0, "Unrecognized option #{violator}: #{Keyword.get(options, violator) |> inspect()} ignored"}
  end

  defp _assure_applicable(fun_or_tuple_or_tsp)
  defp _assure_applicable({_, _}=tf), do: Earmark.TagSpecificProcessors.new(tf)
  defp _assure_applicable(f), do: f

  defp _format_errors(violators, options) do
    violators
    |> Enum.map(&_format_error(&1, options))
  end

  defp _normalize(%__MODULE__{registered_processors: {_, _}=t}=options), do:
    _normalize(%{options|registered_processors: [t]})
  defp _normalize(%__MODULE__{registered_processors: rps}=options) when is_list(rps) do
    %{options | registered_processors: Enum.map(rps, &_assure_applicable/1)}
  end
  defp _normalize(%__MODULE__{registered_processors: f}=options) when is_function(f) do
    %{options | registered_processors: [f]}
  end

end

# SPDX-License-Identifier: Apache-2.0
