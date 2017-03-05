defmodule Earmark.Helpers.AttrParser do

  import Earmark.Helpers.StringHelpers, only: [ behead: 2 ]
  import Earmark.Global.Messages, only: [add_message: 1]

  @type errorlist :: list(String.t)

  @spec parse_attrs(String.t, number()) :: {Map.t, errorlist}
  def parse_attrs(attrs, lnb) do
    { attrs, errors } = _parse_attrs(%{}, attrs, [], lnb)
    emit_errors(errors, lnb)
    attrs
  end

  defp _parse_attrs(dict, attrs, errors, lnb) do
    cond do
      Regex.match?(~r{^\s*$}, attrs) -> {dict, errors}

      match = Regex.run(~r{^\.(\S+)\s*}, attrs) ->
        [ leader, class ] = match
          Map.update(dict, "class", [ class ], &[ class | &1])
          |> _parse_attrs(behead(attrs, leader), errors, lnb)

      match = Regex.run(~r{^\#(\S+)\s*}, attrs) ->
        [ leader, id ] = match
          Map.update(dict, "id", [ id ], &[ id | &1])
          |> _parse_attrs(behead(attrs, leader), errors, lnb)

      # Might we being running into escape issues here too?
      match = Regex.run(~r{^(\S+)=\'([^\']*)'\s*}, attrs) -> #'
      [ leader, name, value ] = match
        Map.update(dict, name, [ value ], &[ value | &1])
        |> _parse_attrs(behead(attrs, leader), errors, lnb)

      # Might we being running into escape issues here too?
      match = Regex.run(~r{^(\S+)=\"([^\"]*)"\s*}, attrs) -> #"
      [ leader, name, value ] = match
        Map.update(dict, name, [ value ], &[ value | &1])
        |> _parse_attrs(behead(attrs, leader), errors, lnb)

      match = Regex.run(~r{^(\S+)=(\S+)\s*}, attrs) ->
        [ leader, name, value ] = match
          Map.update(dict, name, [ value ], &[ value | &1])
          |> _parse_attrs(behead(attrs, leader), errors, lnb)

      match = Regex.run(~r{^(\S+)\s*(.*)}, attrs) ->
        [ _, incorrect, rest  ] = match
        _parse_attrs(dict, rest, [ incorrect | errors ], lnb)

      :otherwise ->
        {dict, [attrs | errors ]}
    end
  end

  defp emit_errors([], _lnb), do: []
  defp emit_errors(errors, lnb), do: add_message({:warning, lnb, "Illegal attributes #{inspect errors} ignored in IAL"})
    
end
