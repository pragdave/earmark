defmodule Earmark2.Scanner.Macros do

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.put_attribute __MODULE__, :_defined_tokens, [] 
    end
  end
  


  defmacro deftoken(name, regex_str) do
    regex = "\\A(#{regex_str})(.*)\\z"
    quote bind_quoted: [name: name, regex: regex] do
      already_defined = Module.get_attribute(__MODULE__, :_defined_tokens)
      Module.put_attribute __MODULE__,
        :_defined_tokens, 
        [{name, Regex.compile!(regex, "u")} | already_defined]
    end
  end

end
