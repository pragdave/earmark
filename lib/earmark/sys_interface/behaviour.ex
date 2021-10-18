defmodule Earmark.SysInterface.Behavior do
  @type file_t :: IO.device() | binary()
  @type result_t :: {:error, binary()} | {:ok, Enumerable.t}
  @callback readlines(file_t()) :: result_t()
end
