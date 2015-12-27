defmodule Earmark.Helpers do

  @doc """
  Expand tabs to multiples of 4 columns
  """
  def expand_tabs(line) do
    if String.contains?(line, "\t") do
      line = Regex.replace(~r{(.*?)\t}, line, &expander/2)
    end
    line
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

  ################################################
  # Detection and Rendering of InlineCode Blocks #
  ################################################

  @doc """
  returns false unless the line leaves a code block open,
  in which case the opening backquotes are returned as a string
  """
  @spec pending_inline_code(String.t()) :: String.t() | :false
  def pending_inline_code( line ) do
    line
    |> behead_unopening_text
    |> has_opening_backquotes
  end

  @inline_pairs ~r'''
   ^(?:
       (?:[^`]|\\`)*      # shortes possible prefix, not consuming unescaped `
       (?<!\\)(`++)       # unescaped `, assuring longest match of `
       .+?                # shortest match before...
       (?<![\\`])\1(?!`)  # closing same length ` sequence
    )+
  '''x
  @spec behead_unopening_text(String.t()) :: String.t()
  # All pairs of sequences of backquotes and text in front and in between
  # are removed from line.
  defp behead_unopening_text( line ) do 
    case Regex.run( @inline_pairs, line, return: :index ) do
      [match_index_tuple | _rest] -> behead( line, match_index_tuple )
      _no_match                   -> line
    end 
  end

  @first_opening_backquotes ~r'''
       ^(?:[^`]|\\`)*      # shortes possible prefix, not consuming unescaped `
       (?<!\\)(`++)        # unescaped `, assuring longest match of `
  '''x
  @spec has_opening_backquotes(String.t()) :: String.t() | :false
  defp has_opening_backquotes line do
    case Regex.run( @first_opening_backquotes, line ) do 
      [_total, opening_backquotes | _rest] -> opening_backquotes
      _no_match                            -> false
    end
  end

  @doc """
  returns false if and only if the line closes a pending inline code
  *without* opening a new one.
  The opening backquotes are passed in as second parameter.
  If the function does not return false it returns the (new or original)
  opening backquotes 
  """
  @spec still_pending_inline_code(String.t(), String.t()) :: String.t() | :false
  def still_pending_inline_code( line, opening_backquotes ) do
    case ( ~r"""
       ^.*?                                 # shortest possible prefix
       (?<!\\)#{opening_backquotes}(?!`)    # unescaped ` with exactly the length of opening_backquotes
      """x |> Regex.run( line, return: :index ) ) do
        [match_index_tuple | _] ->  behead(line, match_index_tuple) |> pending_inline_code
        nil                     ->  opening_backquotes
    end
  end
end
