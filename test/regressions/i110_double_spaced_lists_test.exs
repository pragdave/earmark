defmodule Regressions.I1102spacedListsTest do
  use ExUnit.Case
  
  @quadruple_spaced """
  * alpha
       * beta
           * gamma
  """
  test "four still create a new list" do 
    assert Earmark.as_html!(@quadruple_spaced) == "<ul>\n<li><p>alpha</p>\n<ul>\n<li><p>beta</p>\n<ul>\n<li>gamma\n</li>\n</ul>\n</li>\n</ul>\n</li>\n</ul>\n"
  end

  @double_spaced """
  * alpha
    * beta
      * gamma
  """
  test "two create a new list too" do 
    assert Earmark.as_html!(@double_spaced) == "<ul>\n<li><p>alpha</p>\n<ul>\n<li><p>beta</p>\n<ul>\n<li>gamma\n</li>\n</ul>\n</li>\n</ul>\n</li>\n</ul>\n"
  end

  @single_spaced """
  * alpha
   * beta
    * gamma
  """
  test "single does not create a new list" do 
    assert Earmark.as_html!(@single_spaced) == "<ul>\n<li>alpha\n</li>\n<li>beta\n</li>\n<li>gamma\n</li>\n</ul>\n"
  end

  @no_sublist """
  * alpha
  * omega
  """
  test "no sublists" do 
    assert Earmark.as_html!(@no_sublist) == "<ul>\n<li>alpha\n</li>\n<li>omega\n</li>\n</ul>\n"
  end

  @assure_structure """
  * ul1
        some code
      1. ol2
  2. ol1
      - ul2
          -ul3
  """
  @expected_structure """
  """
  # test "assuring structure" do 
  #   expected = parse( @expected_structure )
  #   actual   = Earmark.as_html!(@assure_structure) |> parse()
  #   assert actual == expected
  # end

  defp parse(html) do
    Floki.parse(html)
    |> Traverse.mapall(&cleanup/1)
  end

  defp cleanup([]), do: Traverse.Ignore
  defp cleanup(x) when is_binary(x), do: String.strip(x)
end
