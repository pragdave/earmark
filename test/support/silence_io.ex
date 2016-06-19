defmodule Test.Support.SilenceIo do
  
  import ExUnit.CaptureIO

  def with_silent_io( group_leader, fun) do 
    capture_io( group_leader, fn ->
      send self(), {:result, fun.()}
    end)
    receive do
      {:result, result} -> result
    end
  end
end
