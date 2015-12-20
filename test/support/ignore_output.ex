defmodule IgnoreOutput do

  defmacro ignore_stderr(do: block) do
    quote do
      IgnoreOutput.in_fun :standard_error, fn ->
        unquote(block)
      end
    end
  end
  defmacro ignore_stdout(do: block) do
    quote do
      IgnoreOutput.in_fun :standard_output, fn ->
        unquote(block)
      end
    end
  end

  defmacro ignore_output(device, do: block) do
    quote do
      IgnoreOutput.in_fun unquote(device), fn ->
        unquote(block)
      end
    end
  end

  @doc """
  Executes fun by capturing and ignoring `device` which can be
  either `:standard_output` or `:standard_error`
  """
  def in_fun device, fun do
    {:ok, string_io} = StringIO.open("")
    case ExUnit.Server.capture_device(device, string_io) do
      {:ok, ref} ->
        try do
          do_capture_io(string_io, fun)
        after
          ExUnit.Server.release_device(ref)
        end

      {:error, :no_device} ->
        _ = StringIO.close(string_io)
        raise "could not find IO device registered at #{device}"
      {:error, :already_captured} ->
        _ = StringIO.close(string_io)
        raise "IO device registered at #{device} is already captured"
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
