defmodule Regressions.I062BangVersionTest  do
  use ExUnit.Case
  import ExUnit.CaptureIO

  @moduletag :wip
  # test "Issue https://github.com/pragdave/earmark/issues/62" do
  #   assert capture_io( :stderr, fn->
  #     Earmark.to_html "hello"
  #   end) == "warning: using `Earmark.to_html` is deprecated, please use `Earmark.as_html!` for the same semantics, or preferably `{:ok, html} = Earmark.as_html`"
  # end
end
