defmodule Regressions.I099IalRenderingTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  
  test "Not associated at all (warning is intentional)" do
    assert capture_io(:stderr, fn ->
      assert "<p>{:hello}</p>\n" == Earmark.to_html( "{:hello}" )
    end) == "<no file>:1: warning: Illegal attributes [\"hello\"] ignored in IAL\n"
  end
  test "Associated but incorrect" do 
    assert capture_io(:stderr, fn ->
      assert "<p>World</p>\n" == Earmark.to_html( "World\n{:hello}" )
    end ) == "<no file>:2: warning: Illegal attributes [\"hello\"] ignored in IAL\n"
  end
  test "Associated but partly incorrect" do 
    assert capture_io(:stderr, fn ->
      assert "<p title=\"world\">World</p>\n" == Earmark.to_html( "World\n{: world* hello title=world}" )
    end ) == "<no file>:2: warning: Illegal attributes [\"hello\", \"world*\"] ignored in IAL\n"
  end
end
