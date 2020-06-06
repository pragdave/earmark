defmodule Earmark.Helpers.TestPureLinkHelpers do

  use ExUnit.Case, async: true
  import Earmark.Helpers.PureLinkHelpers, only: [convert_pure_link: 1]

  describe "Pure Links" do
    test "nothing fancy just a plain link" do
      #                           0....+....1....+...
      result = convert_pure_link("https://a.link.com")
      expected = {{"a", [{"href", "https://a.link.com"}], ["https://a.link.com"]}, 18}
      assert result == expected
    end

    test "trailing parens are not part of it" do
      #                           0....+....1....+...
      result = convert_pure_link("https://a.link.com)")
      expected = {{"a", [{"href", "https://a.link.com"}], ["https://a.link.com"]}, 18}
      assert result == expected
    end

    test "however opening parens are" do
      #                           0....+....1....+...
      result = convert_pure_link("https://a.link.com(")
      expected = {{"a", [{"href", "https://a.link.com("}], ["https://a.link.com("]}, 19}
      assert result == expected
    end

    test "closing parens inside are ok" do
      #                          0....+....1....+....2....+....3....+....4....+
      result = convert_pure_link("http://www.google.com/search?q=(business))+ok")
      expected = {{"a", [{"href", "http://www.google.com/search?q=(business))+ok"}], ["www.google.com/search?q=(business))+ok"]}, 45}
      assert result == expected
    end

    test "closing parens outside are not part of it" do
      #                          0....+....1....+....2....+....3....+....4
      result = convert_pure_link("http://www.google.com/search?q=business)")
      expected = {{"a", [{"href", "http://www.google.com/search?q=business"}], ["www.google.com/search?q=(business))+ok"]}, 39}
      assert result == expected
    end

    test "closing parens can match opening parens at the end" do
      #                          0....+....1....+....2....+....3....+....4.
      result = convert_pure_link("(http://www.google.com/search?q=business)")
      expected = {{"a", [{"href", "www.google.com/search?q=business"}], ["www.google.com/search?q=(business))+ok"]}, 41}
      assert result == expected
    end

    test "opening parens w/o closing parens do not match" do
      result = convert_pure_link("(http://www.google.com/search?q=business")
      assert result == nil
    end
  end

end
