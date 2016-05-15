defmodule Earmark.Helpers do

  @doc """
  Expand tabs to multiples of 4 columns
  """
  def expand_tabs(line) do
    Regex.replace(~r{(.*?)\t}, line, &expander/2)
  end

  defp expander(_, leader) do
    extra = 4 - rem(String.length(leader), 4)
    leader <> pad(extra)
  end

  @doc """
  Remove newlines at end of line
  """
  def remove_line_ending(line) do
    line |> String.rstrip(?\n) |> String.rstrip(?\r)
  end

  defp pad(1), do: " "
  defp pad(2), do: "  "
  defp pad(3), do: "   "
  defp pad(4), do: "    "

  @doc """
  Remove the leading part of a string
  """
  def behead(str, ignore) when is_integer(ignore) do
    String.slice(str, ignore..-1)
  end
  def behead(str, {start, length}), do: behead(str, start + length)

  def behead(str, leading_string) do
    behead(str, String.length(leading_string))
  end

  @doc """
  `Regex.replace` with the arguments in the correct order
  """

  def replace(text, regex, replacement, options \\ []) do
    Regex.replace(regex, text, replacement, options)
  end

  @doc """
  Encode URIs to be included in the `<a>` elements.

  Percent-escapes a URI, and after that escapes any
  `&`, `<`, `>`, `"`, `'`.
  """
  def encode(html) do
    URI.encode(html) |> escape(true)
  end

  @doc """
  Replace <, >, and quotes with the corresponding entities. If
  `encode` is true, convert ampersands, too, otherwise only
   convert non-entity ampersands. 
  """

  def escape(html, encode \\ false)

  def escape(html, false), do: _escape(Regex.replace(~r{&(?!#?\w+;)}, html, "&amp;"))
  def escape(html, _), do: _escape(String.replace(html, "&", "&amp;"))
                                                  
  defp _escape(html) do
    html
    |> String.replace("<",  "&lt;")
    |> String.replace(">",  "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'",  "&#39;")
  end

  @doc """
  Convert numeric entity references to character strings
  """

  def unescape(html), do: unescape(html, [])

  defp unescape("", result) do
    result |> Enum.reverse |> List.to_string
  end

  defp unescape("&colon;" <> rest, result) do
    unescape(rest, [ ":" | result ])
  end

  defp unescape("&#x" <> rest, result) do
    {new_rest, char} = parse_hex_entity(rest, [])
    unescape(new_rest, [ char | result ])
  end

  defp unescape("&#" <> rest, result) do
    {new_rest, char} = parse_decimal_entity(rest, [])
    unescape(new_rest, [ char | result ])
  end

  defp unescape(<< ch :: utf8, rest :: binary>>, result) do
    unescape(rest, [ ch | result ])
  end

  defp parse_hex_entity(";" <> rest, entity) do
    { rest, entity |> Enum.reverse |> List.to_integer(16) }
  end
  
  defp parse_hex_entity(<< ch :: utf8, rest :: binary>>, entity) do
    parse_hex_entity(rest, [ ch | entity ])
  end

  defp parse_decimal_entity(";" <> rest, entity) do
    { rest, entity |> Enum.reverse |> List.to_integer(10) }
  end
  
  defp parse_decimal_entity(<< ch :: utf8, rest :: binary>>, entity) do
    parse_decimal_entity(rest, [ ch | entity ])
  end

  @doc """
  Formats an error message and puts it to stderr
  """
  def emit_error filename, %{lnb: lnb}, error_type, error_message do
    emit_error filename, lnb, error_type, error_message
  end
  def emit_error filename, lnb, error_type, error_message do
    IO.puts(:stderr, "#{filename}:#{lnb}: #{error_type}: #{error_message}")
  end
end
