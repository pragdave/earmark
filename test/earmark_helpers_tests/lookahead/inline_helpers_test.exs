defmodule EarmarkHelpersTests.Lookahead.InlineHelpersTest do
  use ExUnit.Case
  import Earmark.Helpers.InlineHelpers, only: [parse_link: 1]

  test "no match" do 
    assert nil == parse_link("")
  end

  test "still no match" do 
    [ "5", "(", "{", "[()", "[title(url)", "[title(etc)](nourl", "(notitle)" ]
    |> Enum.each( fn src -> assert nil == parse_link(src) end)
  end

  test "base case" do 
    link = "[title](url)"
    assert [link, "title", "url", nil] == parse_link(link) 
  end
end
