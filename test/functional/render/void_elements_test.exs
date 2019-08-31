defmodule VoidElementsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  [
    {~s[<img src="whatevs.png">], nil},
    {~s[<area alt="alt" href="http://some.image.com/image">], nil},
    {~s[<br>], nil},
    {~s[<hr />], ~s[<hr />]},
    {~s[<wbr>], nil},
  ] |> Enum.each( fn {inp, out} ->
      test "#{inp} is transformed to #{out} without errors" do
        stderr_out  = capture_io(:stderr, fn ->
          result = Earmark.as_html!(unquote(inp))
          expected = unquote(out||inp)
          assert result == expected
        end)
        assert stderr_out == ""
      end
    end)
end

# SPDX-License-Identifier: Apache-2.0
