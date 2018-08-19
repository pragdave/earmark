defmodule Earmark2.Scanner.Macros do

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.put_attribute __MODULE__, :_tokens_at_start, [] 
      Module.put_attribute __MODULE__, :_tokens_inside, [] 
    end
  end
  


  @doc """
  defines a token that matches at the start of a line and inside too
  """
  defmacro deftoken(name, regex_str) do
    quote bind_quoted: [name: name, regex_str: regex_str] do
      regex = "\\A(#{regex_str})(.*)\\z" 
      already_defined_at_start = Module.get_attribute(__MODULE__, :_tokens_at_start)
      Module.put_attribute __MODULE__,
        :_tokens_at_start,
        [{name, Regex.compile!(regex, "u")} | already_defined_at_start]
      already_defined_inside = Module.get_attribute(__MODULE__, :_tokens_inside)
      Module.put_attribute __MODULE__,
        :_tokens_inside,
        [{name, Regex.compile!(regex, "u")} | already_defined_inside]
    end
  end

  @doc """
  defines a token that matches only at the start of a line
  """
  defmacro deftokenstart(name, regex_str) do
    quote bind_quoted: [name: name, regex_str: regex_str] do
      regex = "\\A(#{regex_str})(.*)\\z" 
      already_defined_at_start = Module.get_attribute(__MODULE__, :_tokens_at_start)
      Module.put_attribute __MODULE__,
        :_tokens_at_start,
        [{name, Regex.compile!(regex, "u")} | already_defined_at_start]
    end
  end

  @doc """
  defines a token that does not match at the start of a line
  """
  defmacro deftokeninside(name, regex_str) do
    quote bind_quoted: [name: name, regex_str: regex_str] do
      regex = "\\A(#{regex_str})(.*)\\z" 
      already_defined_inside = Module.get_attribute(__MODULE__, :_tokens_inside)
      Module.put_attribute __MODULE__,
        :_tokens_inside,
        [{name, Regex.compile!(regex, "u")} | already_defined_inside]
    end
  end


end
