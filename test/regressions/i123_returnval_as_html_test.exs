defmodule Regressions.I123ReturnvalAsHtmlTest do
  use ExUnit.Case

  test "as_html with no errors" do
    assert Earmark.as_html("para") == {:ok, "<p>para</p>\n", []}
  end

  test "as_html with errors" do
    assert Earmark.as_html("not closed`") == {:error, "<p>not closed`</p>\n", [{:warning, 1, "Closing unclosed backquotes ` at end of input"}]}
  end
  
end
