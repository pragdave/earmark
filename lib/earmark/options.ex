defmodule Earmark.Options do

  @moduledoc """
  This is a superset of the options that need to be passed into `EarmarkParser.as_ast/2`

  The following options are proper to `Earmark` only and therefore explained in detail

  - `compact_output`: boolean indicating to avoid indentation and minimize whitespace
  - `eex`: Coming soon (EEx preprocessing)
  - `file`: Name of file passed in from the CLI
  - `line`: 1 but might be set to an offset for better error messages in some integration cases
  - `ignore_strings`, `postprocessor` and `registered_processors`: processors that modify the AST returned from
     EarmarkParser.as_ast/`2` before rendering (`post` because preprocessing is done on the markdown, e.g. `eex`)
     Refer to the moduledoc of Earmark.`Transform` for details

  All other options are passed onto EarmarkParser.as_ast/`2`
  """

  defstruct [
            breaks: false,
            code_class_prefix: nil,
            compact_output: false,
            # Internal—only override if you're brave
            escape: true,
            file: "<no file>",
            footnote_offset: 1,
            footnotes: false,
            gfm: true,
            gfm_tables: false,
            ignore_strings: false,
            line: 1,
            mapper: &Earmark.pmap/2,
            mapper_with_timeout: &Earmark.pmap/3,
            messages: [],
            pedantic: false,
            postprocessor: nil,
            pure_links: true,
            registered_processors: [],
            smartypants: true,
            timeout: nil,
            wikilinks: false,
          ]

  @doc ~S"""
  Make a legal and normalized Option struct from, maps or keyword lists

  Without a param or an empty input we just get a new Option struct

      iex(0)> { make_options(), make_options(%{}) }
      { {:ok, %Earmark.Options{}}, {:ok, %Earmark.Options{}} }

  The same holds for the bang version of course

      iex(1)> { make_options!(), make_options!(%{}) }
      { %Earmark.Options{}, %Earmark.Options{} }

  When constructed from user input some normalization and error checking needs to be performed

  Firstly we check for unallowed keys

      iex(2)> make_options(no_such_option: true)
      {:error, [{:warning, 0, "Unrecognized option no_such_option: true"}]}

  Of course we do not let our users discover one error after another

      iex(3)> make_options(no_such_option: true, gfm: false, still_not_an_option: 42)
      {:error, [{:warning, 0, "Unrecognized option no_such_option: true"}, {:warning, 0, "Unrecognized option still_not_an_option: 42"}]}

  If everything goes well however, we also make sure that our values are correctly cast

      iex(4)> make_options!(%{gfm: false, timeout: "42_000"})
      %Earmark.Options{gfm: false, timeout: 42_000}

  Unless we cannot, of course

      iex(5)> make_options(timeout: "xxx")
      {:error, [{:warning, 0, "Illegal value for option timeout, actual: \"xxx\", needed: an int or nil"}]}

  Here is a complete example

      iex(6)> make_options(timeout: "yyy", no_such_option: true)
      {:error, [{:warning, 0, "Unrecognized option no_such_option: true"}, {:warning, 0, "Illegal value for option timeout, actual: \"yyy\", needed: an int or nil"}]}

  If we use the bang version we still get the needed information

      iex(7)> try do
      ...(7)>   make_options!(timeout: "yyy", no_such_option: true)
      ...(7)> rescue
      ...(7)>   ee in Earmark.Error -> ee.message
      ...(7)> end
      "[{:warning, 0, \"Unrecognized option no_such_option: true\"}, {:warning, 0, \"Illegal value for option timeout, actual: \\\"yyy\\\", needed: an int or nil\"}]"

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

    {options_, format_errors} = _numberize_values(MapSet.new(~w[timeout]a), options)

    case (illegal_key_errors ++ format_errors) do
      [] -> {:ok, struct(__MODULE__, options_)|>_normalize()}
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

  defp _numberize_this_value(value) do
    case value |> String.replace("_","") |> Integer.parse do
      {int_val, ""}   -> {:ok, int_val}
      _               -> :error
    end
  end

  defp _normalize(%__MODULE__{registered_processors: {_, _}=t}=options), do:
    _normalize(%{options|registered_processors: [t]})
  defp _normalize(%__MODULE__{registered_processors: rps}=options) when is_list(rps) do
    %{options | registered_processors: Enum.map(rps, &_assure_applicable/1)}
  end
  defp _normalize(%__MODULE__{registered_processors: f}=options) when is_function(f) do
    %{options | registered_processors: [f]}
  end

  defp _numberize_value({k, v}, {options, errors}, names) do
    if Enum.member?(names, k) do
      case _numberize_this_value(v) do
        {:ok, value} -> {Keyword.put(options, k, value), errors}
        :error       -> {options, ["Illegal value for option #{k}, actual: #{inspect v}, needed: an int or nil"|errors]}
      end
    else
      {options, errors}
    end
  end

  defp _numberize_values(names, options) do
    options
    |> Enum.reduce({options, []}, &_numberize_value(&1, &2, names))
  end

end

# SPDX-License-Identifier: Apache-2.0
