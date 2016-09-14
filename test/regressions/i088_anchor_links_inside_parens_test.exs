defmodule Regressions.I88AnchorLinksInsideParensTest do
  use ExUnit.Case

  describe "parens" do
    test "minimal case" do 
      result = Earmark.to_html("([]())")
      assert "<p>(<a href=\"\"></a>)</p>\n" == result
    end
    test "normal case" do 
      result = Earmark.to_html( "([text](link))" )
      assert "<p>(<a href=\"link\">text</a>)</p>\n" == result
    end
    test "non regression" do 
      result = Earmark.to_html( "[text](link)" )
      assert "<p><a href=\"link\">text</a></p>\n" == result
    end

    test "images" do 
      result = Earmark.to_html "(![text](link))"
      assert "<p>(<img src=\"link\" alt=\"text\"/>)</p>\n" == result
    end
  end
end
