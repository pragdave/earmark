defmodule Earmark.Messages do
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

  def new_warning(line, text), do: %__MODULE__{line: line, text: text, type: :warning}
end
