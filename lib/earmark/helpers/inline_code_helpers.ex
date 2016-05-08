defmodule Earmark.Helpers.InlineCodeHelpers do

  import Earmark.Helpers.StringHelpers

  @type maybe(t) :: t | :nil
  @type inline_code_continuation :: {maybe(String.t), boolean}
  
  @doc """
  returns false unless the line leaves a code block open,
  in which case the opening backquotes are returned as a string
  """
  @spec opens_inline_code(String.t()) :: inline_code_continuation
  def opens_inline_code( line ) do
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
  @spec has_opening_backquotes(String.t()) :: inline_code_continuation
  defp has_opening_backquotes line do
    case Regex.run( @first_opening_backquotes, line ) do 
      [_total, opening_backquotes | _rest] -> {opening_backquotes, true}
      _no_match                            -> {nil, false}
    end
  end

  @doc """
  returns false if and only if the line closes a pending inline code
  *without* opening a new one.
  The opening backquotes are passed in as second parameter.
  If the function does not return false it returns the (new or original)
  opening backquotes 
  """
   @spec still_inline_code(String.t, String.t) :: inline_code_continuation
  def still_inline_code( line, pending ) do
      case ( ~r"""
       ^.*?                                 # shortest possible prefix
       (?<![\\`])#{pending}(?!`)    # unescaped ` with exactly the length of opening_backquotes
      """x |> Regex.run( line, return: :index ) ) do
        [match_index_tuple | _] ->  behead(line, match_index_tuple) |> opens_inline_code
        nil                     ->  {pending, false}
    end
  end

end
