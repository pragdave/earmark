defmodule Earmark.Message do

  @type message_type :: :error | :warning
  @type t :: {message_type, number, binary}
  @type ts:: list(t)

  @doc """
    Formats a message as a string
  """
  @spec format_message( String.t, t ) :: String.t
  def format_message filename, {type, line, text} do
    "#{filename}:#{line}: #{type}: #{text}"
  end

  def emit_messages(filename, messages, device \\ :stderr), do:
    Enum.each(messages, &(emit_message(filename, &1, device)))

  defp emit_message(filename, msg, device), do:
    IO.puts(device, format_message(filename, msg))

  @doc false
  def new_error(line, text), do: new_message({:warning, line, text})
  @doc false
  def new_message({type, line, text}), do: {type, line, text}
  @doc false
  def new_warning(line, text), do: new_message({:warning, line, text})
end
