defmodule Earmark.Message do

  @type message_type :: :error | :warning
  @type t :: {message_type, number, binary}
  @type ts:: list(t)


  def emit_messages(filename, messages, device \\ :stderr), do:
    Enum.each(messages, &(emit_message(filename, &1, device)))

  defp emit_message(filename, msg, device), do:
    IO.puts(device, format_message(filename, msg))

  @spec format_message( String.t, t ) :: String.t
  defp format_message filename, {type, line, text} do
    "#{filename}:#{line}: #{type}: #{text}"
  end
end
