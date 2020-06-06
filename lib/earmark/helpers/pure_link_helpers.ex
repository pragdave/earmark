defmodule Earmark.Helpers.PureLinkHelpers do
  @moduledoc false

  import Earmark.Helpers.StringHelpers, only: [behead: 2]
  import Earmark.Helpers.AstHelpers, only: [render_link: 2]

  @pure_link_rgx ~r{\A(\s*)(\()?(https?://[[:alnum:]@:-_()]*)}u
  def convert_pure_link(src) do
    case Regex.run(@pure_link_rgx, src) do
      [match, spaces, "", link_text] -> reparse_link(String.length(spaces), link_text, 0)
      [match, spaces, _, link_text]  -> reparse_link(String.length(spaces), link_text, 1)
      _ -> nil
    end
  end

  @split_at_ending_parens ~r{(.*?)(\)*)\z}
  defp reparse_link(leading_spaces_count, link_text, open_count) do
    [_, prefix, suffix] = Regex.run(@split_at_ending_parens, link_text)
    nof_closing_parens = String.length(suffix)
    if nof_closing_parens >= open_count do
      determine_ending_parens_by_count(leading_spaces_count, prefix, nof_closing_parens - open_count)
    end
  end

  # TODO: Fix length issues
  # TODO: Remove if
  # TODO: call render_link on first result tuple element
  defp determine_ending_parens_by_count(leading_spaces_count, prefix, surplus_on_closing_parens) do
    graphemes = String.graphemes(prefix)
    open_parens_count = Enum.count(graphemes, &(&1 == "("))
    close_parens_count = Enum.count(graphemes, &(&1 == ")"))
    delta = open_parens_count - close_parens_count
    if delta <= 0 do
       {prefix, leading_spaces_count + String.length(prefix)} 
    else
       take = min(delta, surplus_on_closing_parens)
       needed =
         (1..take)
         |> Enum.map(fn _ -> ")" end)
         |> Enum.join
       {prefix <> needed, String.length(prefix) + leading_spaces_count + take} 
    end
  end
    
end
