defmodule Earmark.Helpers.AttrParser do

  import Earmark.Helpers.StringHelpers, only: [ behead: 2 ]

  @type errorlist :: list(String.t)

  @spec parse_attrs(String.t) :: {Map.t, errorlist}
  def parse_attrs(attrs) do
    _parse_attrs(%{}, attrs, [])
  end

  defp _parse_attrs(dict, attrs, errors) do
    cond do
      Regex.match?(~r{^\s*$}, attrs) -> {dict, errors}

      match = Regex.run(~r{^\.(\S+)\s*}, attrs) ->
        [ leader, class ] = match
          Map.update(dict, "class", [ class ], &[ class | &1])
          |> _parse_attrs(behead(attrs, leader), errors)

      match = Regex.run(~r{^\#(\S+)\s*}, attrs) ->
        [ leader, id ] = match
          Map.update(dict, "id", [ id ], &[ id | &1])
          |> _parse_attrs(behead(attrs, leader), errors)

      # Might we being running into escape issues here too?
      match = Regex.run(~r{^(\S+)=\'([^\']*)'\s*}, attrs) -> #'
      [ leader, name, value ] = match
        Map.update(dict, name, [ value ], &[ value | &1])
        |> _parse_attrs(behead(attrs, leader), errors)

      # Might we being running into escape issues here too?
      match = Regex.run(~r{^(\S+)=\"([^\"]*)"\s*}, attrs) -> #"
      [ leader, name, value ] = match
        Map.update(dict, name, [ value ], &[ value | &1])
        |> _parse_attrs(behead(attrs, leader), errors)

      match = Regex.run(~r{^(\S+)=(\S+)\s*}, attrs) ->
        [ leader, name, value ] = match
          Map.update(dict, name, [ value ], &[ value | &1])
          |> _parse_attrs(behead(attrs, leader), errors)

      match = Regex.run(~r{^(\S+)\s*(.*)}, attrs) ->
        [ _, incorrect, rest  ] = match
        _parse_attrs( dict, rest, [ incorrect | errors ] )

      :otherwise ->
        {dict, [attrs | errors ]}
    end
end
end
