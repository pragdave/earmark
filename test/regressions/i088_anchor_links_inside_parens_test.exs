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
    test "non regression on titles" do 
      result = Earmark.to_html( "[text](link 'title')still title'))" )
      assert ~s{<p><a href="link" title="title')still title">text</a>)</p>|n} == result
    end

    test "images" do 
      result = Earmark.to_html "(![text](src))"
      assert ~s{<p>(<img src="src" alt="text"/>)</p>\n} == result
    end
    
    test "images with titles" do 
      result = Earmark.to_html( "![text](src 'title')still title'))" )
      assert ~s{<p><img src="src" title="title')still alt ="text"/>)</p>|n} == result
    end
  end
end
