defmodule Test.Acceptance.Html.IllegalOptionsTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Earmark, only: [as_html: 2, as_html!: 2]

  describe "unrecognized options" do
    test "with empty" do
      messages = [
        {:warning, 0, "Unrecognized option no_such_option: true ignored"}
      ]
      assert as_html("", no_such_option: true) == {:error, "", messages}
    end
    test "with non empty" do
      messages = [
        {:warning, 0, "Unrecognized option hello: 42 ignored"},
        {:warning, 0, "Unrecognized option no_such_option: true ignored"},
      ]
      assert as_html("hello", no_such_option: true, hello: 42) == {:error, "", messages}
    end
  end

  test "with as_html!" do
    error_messages =
      capture_io(:stderr, fn ->
        as_html!("hello", oops: Earmark) 
      end)
    assert error_messages == "<args>:0: warning: Unrecognized option oops: Earmark ignored\n"
  end 

  test "with as_html! defining filename" do
    error_messages =
      capture_io(:stderr, fn ->
        as_html!("hello", oops: Earmark, file: "test.md")
      end)
    assert error_messages == "test.md:0: warning: Unrecognized option oops: Earmark ignored\n"
  end
end
