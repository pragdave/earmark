defmodule Support.Html1Helpers do

  def to_html1(markdown, options \\ []) do
    {status, ast, messages} = Earmark.as_ast(markdown, options)
    if System.get_env("DEBUG") do
      IO.inspect({:ast, ast})
    end
    {status, Earmark.Transform.transform(ast, options), messages}
  end

  def to_html2(markdown, options \\ []) do
    {:ok, ast, []} = Earmark.as_ast(markdown, options)
    if System.get_env("DEBUG") do
      IO.inspect({:ast, ast})
    end
    ast
    |> Earmark.Transform.transform(options)
    |> parse_trimmed()
  end


  def construct(constructions, indent \\ 2) do
    result =
    _construct(constructions, 0, [], indent) |> IO.iodata_to_binary
    if System.get_env("DEBUG") do
      IO.inspect({:constructed, result})
    end
    result
  end

  def icode(code) when is_binary(code) do
    ~s{<pre><code>#{code}</code></pre>\n}
  end

  def fcode(code, lang)
  def fcode(code, lang) do
    ~s{<pre><code class="#{lang}">#{code}</code></pre>\n}
  end

  def para(constructions, indent \\ 2)
  def para(construction, indent) when is_binary(construction), do: construct([:p, construction], indent)
  def para(constructions, indent), do: construct([:p|constructions], indent)

  def parse_trimmed(html) do
    html
    |> Floki.parse
    |> Traverse.map!(fn x when is_binary(x) -> String.trim(x) end)
  end

  def td(content, style \\ "left") do
    {:td, ~s{style="text-align: #{style};"}, content}
  end

  def th(content, style \\ "left") do
    {:th, ~s{style="text-align: #{style};"}, content}
  end

  defp _construct(constructions, indent, open, iby)
  defp _construct([], _indent, [], _iby), do: []
  defp _construct([], indent, [open|rest], iby) do
    [_indent(indent - iby), "</", to_string(open), ">\n", _construct([], indent - iby, rest, iby) ]
  end
  defp _construct([:POP|rest], indent, [tag|rest1], iby) do
    [_indent(indent-iby), "</", to_string(tag), ">\n", _construct(rest, indent - iby, rest1, iby)]
  end
  defp _construct(head, indent, open, iby) when is_tuple(head) do
    _construct([head], indent, open, iby)
  end
  defp _construct([:br | rest], indent, open, iby) do
    _void_tag("<br />\n", rest, indent, open, iby)
  end
  defp _construct([:hr | rest], indent, open, iby) do
    _void_tag("<hr />\n", rest, indent, open, iby)
  end
  defp _construct([:wbr | rest], indent, open, iby) do
    _void_tag("<wbr />\n", rest, indent, open, iby)
  end
  defp _construct([{:area, atts} | rest], indent, open, iby) do
    _void_tag_with_atts("<area ", atts, rest, indent, open, iby)
  end
  defp _construct([{:hr, atts} | rest], indent, open, iby) do
    _void_tag_with_atts("<hr ", atts, rest, indent, open, iby)
  end
  defp _construct([{:img, atts} | rest], indent, open, iby) do
    _void_tag_with_atts("<img ", atts, rest, indent, open, iby)
  end
  defp _construct([tag | rest], indent, open, iby) when is_atom(tag) do
    [_indent(indent), "<", to_string(tag), ">", "\n", _construct(rest, indent + iby, [tag | open], iby)]
  end
  defp _construct([content|rest], indent, open, iby) when is_binary(content) do
    [_indent(indent), content, "\n", _construct(rest, indent, open, iby)]
  end
  defp _construct([{tag, content}|rest], indent, open, iby) when is_tuple(content), do: _construct([{tag, nil, content}|rest], indent, open, iby)
  defp _construct([{tag, content}|rest], indent, open, iby) when is_list(content), do: _construct([{tag, nil, content}|rest], indent, open, iby)
  defp _construct([{tag, atts}|rest], indent, open, iby) do
    [_indent(indent), "<", to_string(tag), " ", atts, ">", "\n", _construct(rest, indent + iby, [tag | open], iby)]
  end
  defp _construct([{tag, atts, content}|rest], indent, open, iby) when is_binary(content) do
    _construct([{tag, atts, [content]}|rest], indent, open, iby)
  end
  defp _construct([{tag, nil, content}|rest], indent, open, iby) do
    [_indent(indent), "<", to_string(tag), ">",
     "\n",
     _construct(content, indent + iby, [], iby),
     _indent(indent), "</", to_string(tag), ">\n",
     _construct(rest, indent, open, iby)]
  end
  defp _construct([{tag, atts, content}|rest], indent, open, iby) do
    [_indent(indent), "<", to_string(tag), " ", atts, ">",
     "\n",
     _construct(content, indent + iby, [], iby),
     _indent(indent), "</", to_string(tag), ">\n",
     _construct(rest, indent, open, iby)]
  end

  defp _indent(n), do: Stream.cycle([" "]) |> Enum.take(n)

  defp _void_tag( tag, rest, indent, open, iby) do
    [_indent(indent), tag, _construct(rest, indent, open, iby)]
  end

  defp _void_tag_with_atts(tag, atts, rest, indent, open, iby) do
    [_indent(indent), tag, atts, " />", "\n", _construct(rest, indent, open, iby)]
  end
end
