defmodule Regressions.I062RefactorToHtmlTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "deprecation warning for to_html" do 
    assert capture_io( :stderr, fn->
      Earmark.to_html("* hello")
    end) == "warning: usage of `Earmark.to_html` is deprecated.\nUse `Earmark.as_html!` instead, or use `Earmark.as_html` which returns a tuple `{html, warnings, errors}`\n"
  end

  test "as_html! takes place" do 
    assert Earmark.as_html!("* hello") == "<ul>\n<li>hello\n</li>\n</ul>\n"
  end
  
end
