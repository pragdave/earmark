defmodule Regressions.I099IalRenderingTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  
  test "Not associated at all" do
    assert "<p>{:hello}</p>\n" == Earmark.to_html( "{:hello}" )
  end
  test "Associated but incorrect" do 
    assert capture_io(:stderr, fn ->
      assert "<p>World</p>\n" == Earmark.to_html( "World\n{:hello}" )
    end ) == "<no file>:2: warning: Ignoring illegal html attribute specification \"hello\""
  end
  test "Associated but partly incorrect" do 
    assert capture_io(:stderr, fn ->
      assert "<p title=\"world\">World</p>\n" == Earmark.to_html( "World\n{:hello title=world}" )
    end ) == "<no file>:2: warning: Ignoring illegal html attribute specification \"hello\""
  end
end
