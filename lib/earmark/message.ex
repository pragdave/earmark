defmodule Earmark.Message do
  defstruct type: :warning, # or :error
            line: 1,
            text: "oooooh noooo no such soooo"

  @type t :: %__MODULE__{}
  @type ts:: list(t)

  @doc """
    Formats a message as a string
  """
  @spec format_message( String.t, t ) :: String.t
  def format_message filename, %{line: line, type: type, text: text} do
    "#{filename}:#{line}: #{type}: #{text}"
  end

  def emit_messages(filename, messages, device \\ :stderr), do: 
    Enum.each(messages, &(emit_message(filename, &1, device)))

  defp emit_message(filename, msg, device), do:
    IO.puts(device, format_message(filename, msg))

  def new_error(line, text), do: %__MODULE__{line: line, text: text, type: :error}
  def new_warning(line, text), do: %__MODULE__{line: line, text: text, type: :warning}
end
