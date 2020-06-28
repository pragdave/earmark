defmodule Earmark.Helpers.PureLinkHelpers do
  @moduledoc false

  import Earmark.Helpers.StringHelpers, only: [betail: 2]
  import Earmark.Helpers.AstHelpers, only: [render_link: 2]

  @pure_link_rgx ~r{\A(\s*)(\()?(https?://[[:alnum:]"'*@:+-_{\}()/.%\#]*)}u
  def convert_pure_link(src) do
    case Regex.run(@pure_link_rgx, src) do
      [_match, spaces, "", link_text] -> reparse_link(String.length(spaces), link_text, 0)
      [_match, spaces, _, link_text]  -> remove_trailing_closing_parens(String.length(spaces), link_text) 
      _ -> nil
      end
  end

  defp determine_ending_parens_by_count(leading_spaces_count, prefix, surplus_on_closing_parens) do
    graphemes = String.graphemes(prefix)
    open_parens_count = Enum.count(graphemes, &(&1 == "("))
    close_parens_count = Enum.count(graphemes, &(&1 == ")"))
    delta = open_parens_count - close_parens_count
    take = min(delta, surplus_on_closing_parens)
    needed =
    :lists.duplicate(max(0, take), ")")
    |> Enum.join
    {link(prefix <> needed), String.length(prefix) + leading_spaces_count + max(0,take)} 
  end

  @split_at_ending_parens ~r{(.*?)(\)*)\z}
  defp remove_trailing_closing_parens(leading_spaces_count, link_text) do
    [_, _prefix, suffix] = Regex.run(@split_at_ending_parens, link_text)
    case suffix do
      "" -> {"(", leading_spaces_count + 1}
      _  -> case convert_pure_link(betail(link_text, 1)) do
        {link, length} -> {["(", link, ")"], length + 2}
        _ -> nil
      end
    end
  end

  defp reparse_link(leading_spaces_count, link_text, open_count) do
    [_, prefix, suffix] = Regex.run(@split_at_ending_parens, link_text)
    nof_closing_parens = String.length(suffix)
    if nof_closing_parens >= open_count do
      determine_ending_parens_by_count(leading_spaces_count, prefix, nof_closing_parens - open_count)
    end
  end

  defp link(text), do: render_link(text, text)

end
