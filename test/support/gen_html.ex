defmodule Support.GenHtml do
  
  @increment 2

  def img(atts), do: para({:img, atts, nil})

  def gen(list) do
    list
    |> _gen(0)
    |> IO.iodata_to_binary
  end

  def link(children, atts \\ []) do
    para({:a, atts, children})
  end

  def para(elements), do: gen({:p, elements})

  defp _gen(input, level)
  defp _gen(elements, level) when is_list(elements) do
    elements
    |> Enum.map(&_gen1(&1, level))
  end
  defp _gen(element, level), do: _gen1(element, level)

  defp _gen1(element, level)
  defp _gen1(string, level) when is_binary(string), do: _indent(string, level)
  defp _gen1(symbol, level) when is_atom(symbol), do: _indent("<#{symbol} />", level)
  defp _gen1({symbol, children}, level), do: _gen1({symbol, [], children}, level)
  defp _gen1({symbol, atts, nil}, level) do
    _indent("<#{symbol}#{_mk_atts(atts)} />", level)
  end
  defp _gen1({symbol, atts, []}, level) do
    _indent("<#{symbol}#{_mk_atts(atts)}></#{symbol}>", level)
  end
  defp _gen1({symbol, atts, children}, level) do
    [ _indent("<#{symbol}#{_mk_atts(atts)}>", level),
      _gen(children, level + @increment),
     _indent("</#{symbol}>", level) ]
  end

  defp _indent(string, level), do: "#{String.duplicate(" ", level)}#{string}\n"

  defp _mk_atts(atts)
  defp _mk_atts([]), do: ""
  defp _mk_atts(atts) do
    " " <> (atts
    |> Enum.map(&_mk_att/1)
    |> Enum.join(" "))
  end

  defp _mk_att({key, value}), do: ~s{#{key}="#{value}"}

end
