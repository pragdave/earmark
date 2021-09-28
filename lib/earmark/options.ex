defmodule Earmark.Options do

  @moduledoc """
  This is a superset of the options that need to be passed into `EarmarkParser.as_ast/2`

  The following options are proper to `Earmark` only and therefore explained in detail

  - `compact_output`: boolean indicating to avoid indentation and minimize whitespace
  - `eex`: Allows usage of an `EEx` template to be expanded to markdown before conversion
  - `file`: Name of file passed in from the CLI
  - `line`: 1 but might be set to an offset for better error messages in some integration cases
  - `ignore_strings`, `postprocessor` and `registered_processors`: processors that modify the AST returned from
     EarmarkParser.as_ast/`2` before rendering (`post` because preprocessing is done on the markdown, e.g. `eex`)
     Refer to the moduledoc of Earmark.`Transform` for details

  All other options are passed onto EarmarkParser.as_ast/`2`
  """

  defstruct [
            annotations: nil,
            breaks: false,
            code_class_prefix: nil,
            compact_output: false,
            # Internal—only override if you're brave
            eex: false,
            escape: true,
            file: nil,
            footnote_offset: 1,
            footnotes: false,
            gfm: true,
            gfm_tables: false,
            ignore_strings: false,
            inner_html: false,
            line: 1,
            mapper: &Earmark.pmap/2,
            mapper_with_timeout: &Earmark.pmap/3,
            messages: [],
            pedantic: false,
            postprocessor: nil,
            pure_links: true,
            registered_processors: [],
            smartypants: true,
            template: false,
            timeout: nil,
            wikilinks: false,
          ]

  @doc ~S"""
  Make a legal and normalized Option struct from, maps or keyword lists

  Without a param or an empty input we just get a new Option struct

      iex(1)> { make_options(), make_options(%{}) }
      { {:ok, %Earmark.Options{}}, {:ok, %Earmark.Options{}} }

  The same holds for the bang version of course

      iex(2)> { make_options!(), make_options!(%{}) }
      { %Earmark.Options{}, %Earmark.Options{} }


  We check for unallowed keys

      iex(3)> make_options(no_such_option: true)
      {:error, [{:warning, 0, "Unrecognized option no_such_option: true"}]}

  Of course we do not let our users discover one error after another

      iex(4)> make_options(no_such_option: true, gfm: false, still_not_an_option: 42)
      {:error, [{:warning, 0, "Unrecognized option no_such_option: true"}, {:warning, 0, "Unrecognized option still_not_an_option: 42"}]}

  And the bang version will raise an `Earmark.Error` as excepted (sic)

      iex(5)> make_options!(no_such_option: true, gfm: false, still_not_an_option: 42)
      ** (Earmark.Error) [{:warning, 0, "Unrecognized option no_such_option: true"}, {:warning, 0, "Unrecognized option still_not_an_option: 42"}]
  """

  def make_options(options \\ [])
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

    illegal_key_errors =
      given_keys
      |> MapSet.difference(legal_keys)
      |> _format_illegal_key_errors(options)


    case illegal_key_errors do
      [] -> {:ok, struct(__MODULE__, options)|> _normalize()}
      errors -> {:error, _format_errors(errors)}
    end
  end
  def make_options(options) when is_map(options) do
    options
    |> Enum.into([])
    |> make_options()
  end

  def make_options!(options \\ []) do
    case make_options(options) do
      {:ok, options_} -> options_

      {:error, errors} -> raise Earmark.Error, inspect(errors)
    end
  end

  @doc """
  A convenience constructor
  """
  def with_postprocessor(pp, rps \\ []), do: %__MODULE__{postprocessor: pp, registered_processors: rps}

  defp _assure_applicable(fun_or_tuple_or_tsp)
  defp _assure_applicable({_, _}=tf), do: Earmark.TagSpecificProcessors.new(tf)
  defp _assure_applicable(f), do: f

  defp _format_errors(errors) do
    errors
    |> Enum.map(&{:warning, 0, &1})
  end

  defp _format_illegal_key_errors(violators, options) do
    violators
    |> Enum.map(&_format_illegal_key_error(&1, options))
  end

  defp _format_illegal_key_error(violator, options) do
    "Unrecognized option #{violator}: #{Keyword.get(options, violator) |> inspect()}"
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
