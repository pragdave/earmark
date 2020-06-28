defmodule Earmark.Helpers.TestPureLinkHelpers do

  use ExUnit.Case, async: true
  import Earmark.Helpers.PureLinkHelpers, only: [convert_pure_link: 1]
  import EarmarkAstDsl

  describe "Pure Links" do
    test "nothing fancy just a plain link" do
      #                           0....+....1....+...
      result = convert_pure_link("https://a.link.com")
      expected = { tag("a", "https://a.link.com", href: "https://a.link.com"), 18}
      assert result == expected
    end

    test "trailing parens are not part of it" do
      #                           0....+....1....+...
      result = convert_pure_link("https://a.link.com)")
      expected = {tag("a", "https://a.link.com", href: "https://a.link.com"), 18}
      assert result == expected
    end

    test "trailing parens are not part of it, at least not all" do
      #                          0....+....1....+....2.
      result = convert_pure_link("(https://a.link.com))")
      expected = {["(", tag("a",  "https://a.link.com", href:  "https://a.link.com"), ")"], 20}
      assert result == expected
    end


    test "however opening parens are" do
      #                           0....+....1....+...
      result = convert_pure_link("https://a.link.com(")
      expected = {tag("a",  "https://a.link.com(", href:  "https://a.link.com("), 19}
      assert result == expected
    end

    test "closing parens inside are ok" do
      #                          0....+....1....+....2....+....3....+....4....+
      result = convert_pure_link("http://www.google.com/search?q=(business))+ok")
      expected = {tag("a",  "http://www.google.com/search?q=(business))+ok", href:  "http://www.google.com/search?q=(business))+ok"), 45}
      assert result == expected
    end

    test "closing parens outside are not part of it" do
      #                          0....+....1....+....2....+....3....+....4
      result = convert_pure_link("http://www.google.com/search?q=business)")
      expected = {tag("a", "http://www.google.com/search?q=business", href: "http://www.google.com/search?q=business"), 39}
      assert result == expected
    end

    test "closing parens can match opening parens at the end" do
      #                          0....+....1....+....2....+....3....+....4.
      result = convert_pure_link("(http://www.google.com/search?q=business)")
      expected = {["(", tag("a", "http://www.google.com/search?q=business", href: "http://www.google.com/search?q=business"), ")"], 41}
      assert result == expected
    end

    test "opening parens w/o closing parens do not match" do
      result = convert_pure_link("(http://www.google.com/search?q=business")
      assert result == {"(", 1} 
    end
  end

end
