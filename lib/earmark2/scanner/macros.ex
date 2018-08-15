defmodule Earmark2.Scanner.Macros do

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.put_attribute __MODULE__, :_defined_tokens,%{} 
    end
  end
  


  defmacro deftoken(name, regex_str) do
    regex = "\\A(#{regex_str})(.*)\\z"
    quote bind_quoted: [name: name, regex: regex] do
      already_defined = Module.get_attribute(__MODULE__, :_defined_tokens)
      Module.put_attribute __MODULE__, :_defined_tokens, Map.put(already_defined, name, Regex.compile!(regex, "u"))
    end
  end

  defmacro match(line) do
    quote do
      @_defined_tokens
      |> Enum.find_value(&match_token(&1, unquote(line)))
    end
  end


  def match_token( {token_name, token_rgx}, line ) do
    case Regex.run(token_rgx, line) do
      [_, token_string, rest] -> {{token_name, token_string}, rest}
      _                       -> nil
    end
  end
end
