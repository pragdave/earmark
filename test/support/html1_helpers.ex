defmodule Support.Html1Helpers do

  def to_html1(markdown, options \\ []) do
    {status, ast, messages} = Earmark.as_ast(markdown, options)
    if System.get_env("DEBUG") do
      IO.inspect({:ast, ast})
    end
    {status, Earmark.Transform.transform(ast, options), messages}
  end


  def construct(constructions) do
    result =
    _construct(constructions, 0, []) |> IO.iodata_to_binary
    if System.get_env("DEBUG") do
      IO.inspect({:constructed, result})
    end
    result
  end

  def icode(constructions)
  def icode(construction) when is_binary(construction), do: construct([:pre, :code, construction])
  def icode(constructions), do: construct([:pre, :code | constructions])

  def para(constructions)
  def para(construction) when is_binary(construction), do: construct([:p, construction])
  def para(constructions), do: construct([:p|constructions])

  defp _construct(constructions, indent, open)
  defp _construct([], _indent, []), do: []
  defp _construct([], indent, [open|rest]) do
    [_indent(indent - 2), "</", to_string(open), ">\n", _construct([], indent - 2, rest) ]
  end
  defp _construct([:POP|rest], indent, [tag|rest1]) do
    [_indent(indent-2), "</", to_string(tag), ">\n", _construct(rest, indent - 2, rest1)]
  end
  defp _construct(head, indent, open) when is_tuple(head) do
    _construct([head], indent, open)
  end
  defp _construct([:br | rest], indent, open) do
    _void_tag("<br />\n", rest, indent, open)
  end
  defp _construct([:hr | rest], indent, open) do
    _void_tag("<hr />\n", rest, indent, open)
  end
  defp _construct([:wbr | rest], indent, open) do
    _void_tag("<wbr />\n", rest, indent, open)
  end
  defp _construct([{:area, atts} | rest], indent, open) do
    _void_tag_with_atts("<area ", atts, rest, indent, open)
  end
  defp _construct([{:hr, atts} | rest], indent, open) do
    _void_tag_with_atts("<hr ", atts, rest, indent, open)
  end
  defp _construct([{:img, atts} | rest], indent, open) do
    _void_tag_with_atts("<img ", atts, rest, indent, open)
  end
  defp _construct([tag | rest], indent, open) when is_atom(tag) do
    [_indent(indent), "<", to_string(tag), ">", "\n", _construct(rest, indent + 2, [tag | open])]
  end
  defp _construct([content|rest], indent, open) when is_binary(content) do
    [_indent(indent), content, "\n", _construct(rest, indent, open)]
  end
  defp _construct([{tag, content}|rest], indent, open) when is_tuple(content), do: _construct([{tag, nil, content}|rest], indent, open)
  defp _construct([{tag, content}|rest], indent, open) when is_list(content), do: _construct([{tag, nil, content}|rest], indent, open)
  defp _construct([{tag, atts}|rest], indent, open) do
    [_indent(indent), "<", to_string(tag), " ", atts, ">", "\n", _construct(rest, indent + 2, [tag | open])]
  end
  defp _construct([{tag, atts, content}|rest], indent, open) when is_binary(content) do
    _construct([{tag, atts, [content]}|rest], indent, open)
  end
  defp _construct([{tag, nil, content}|rest], indent, open) do
    [_indent(indent), "<", to_string(tag), ">",
     "\n",
     _construct(content, indent + 2, []),
     _indent(indent), "</", to_string(tag), ">\n",
     _construct(rest, indent, open)]
  end
  defp _construct([{tag, atts, content}|rest], indent, open) do
    [_indent(indent), "<", to_string(tag), " ", atts, ">",
     "\n",
     _construct(content, indent + 2, []),
     _indent(indent), "</", to_string(tag), ">\n",
     _construct(rest, indent, open)]
  end

  defp _indent(n), do: Stream.cycle([" "]) |> Enum.take(n)

  defp _void_tag( tag, rest, indent, open) do
    [_indent(indent), tag, _construct(rest, indent, open)]
  end

  defp _void_tag_with_atts(tag, atts, rest, indent, open) do
    [_indent(indent), tag, atts, " />", "\n", _construct(rest, indent, open)]
  end
end
