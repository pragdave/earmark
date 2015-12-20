defmodule IgnoreStderr do

  def in_fun fun do
    {:ok, string_io} = StringIO.open("")
    case ExUnit.Server.capture_device(:standard_error, string_io) do
      {:ok, ref} ->
        try do
          do_capture_io(string_io, fun)
        after
          ExUnit.Server.release_device(ref)
        end
      {:error, :no_device} ->
        _ = StringIO.close(string_io)
        raise "could not find IO device registered at :standard_error"
      {:error, :already_captured} ->
        _ = StringIO.close(string_io)
        raise "IO device registered at :standard_error is already captured"
    end
  end

  defp do_capture_io(string_io, fun) do
    try do
      fun.()
    catch
      kind, reason ->
        stack = System.stacktrace()
        _ = StringIO.close(string_io)
        :erlang.raise(kind, reason, stack)
    end
  end

end
