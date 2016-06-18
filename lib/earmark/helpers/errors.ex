defmodule Earmark.Helpers.Errors do

  defmodule Location, do: defstruct lnb: 1, message: "", type: :error

  @type t :: %Location{}
  @type ts :: [t]

  @doc """
  Formats an error message and puts it to stderr
  """
  def emit_error filename, %Location{lnb: lnb, message: message, type: type} do
    _emit_error filename, lnb, type, message
  end
  def emit_error filename, %{lnb: lnb}, error_type, error_message do
    _emit_error filename, lnb, error_type, error_message
  end
  
  defp _emit_error filename, lnb, error_type, error_message do
    IO.puts(:stderr, "#{filename}:#{lnb}: #{error_type}: #{error_message}")
  end
end
